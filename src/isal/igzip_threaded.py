import io
import multiprocessing
import os
import queue
import struct
import threading
from typing import BinaryIO, List, Tuple

from . import igzip, isal_zlib

DEFLATE_WINDOW_SIZE = 2 ** 15


def open(filename, mode="rb", compresslevel=igzip._COMPRESS_LEVEL_TRADEOFF,
         encoding=None, errors=None, newline=None, *, threads=-1):
    if threads == 0:
        return igzip.open(filename, mode, compresslevel, encoding, errors,
                          newline)
    elif threads < 0:
        try:
            threads = len(os.sched_getaffinity(0))
        except:  # noqa: E722
            try:
                threads = multiprocessing.cpu_count()
            except:  # noqa: E722
                threads = 1
    open_mode = mode.replace("t", "b")
    if isinstance(filename, (str, bytes)) or hasattr(filename, "__fspath__"):
        binary_file = io.open(filename, open_mode)
    elif hasattr(filename, "read") or hasattr(filename, "write"):
        binary_file = filename
    else:
        raise TypeError("filename must be a str or bytes object, or a file")
    if "r" in mode:
        gzip_file = io.BufferedReader(ThreadedGzipReader(binary_file))
    else:
        gzip_file = io.BufferedWriter(
            ThreadedGzipWriter(binary_file, compresslevel, threads),
            buffer_size=1024 * 1024
        )
    if "t" in mode:
        return io.TextIOWrapper(gzip_file, encoding, errors, newline)
    return gzip_file


class ThreadedGzipReader(io.RawIOBase):
    def __init__(self, fp, queue_size=4, block_size=8 * 1024 * 1024):
        self.raw = fp
        self.fileobj = igzip._IGzipReader(fp, buffersize=8 * 1024 * 1024)
        self.pos = 0
        self.read_file = False
        self.queue = queue.Queue(queue_size)
        self.eof = False
        self.exception = None
        self.buffer = io.BytesIO()
        self.block_size = block_size
        self.worker = threading.Thread(target=self._decompress)
        self.running = True
        self.worker.start()

    def _decompress(self):
        block_size = self.block_size
        block_queue = self.queue
        while self.running:
            try:
                data = self.fileobj.read(block_size)
            except Exception as e:
                self.exception = e
                return
            if not data:
                return
            while self.running:
                try:
                    block_queue.put(data, timeout=0.05)
                    break
                except queue.Full:
                    pass

    def readinto(self, b):
        result = self.buffer.readinto(b)
        if result == 0:
            while True:
                try:
                    data_from_queue = self.queue.get(timeout=0.01)
                    break
                except queue.Empty:
                    if not self.worker.is_alive():
                        if self.exception:
                            raise self.exception
                        # EOF reached
                        return 0
            self.buffer = io.BytesIO(data_from_queue)
            result = self.buffer.readinto(b)
        self.pos += result
        return result

    def readable(self) -> bool:
        return True

    def writable(self) -> bool:
        return False

    def tell(self) -> int:
        return self.pos

    def close(self) -> None:
        self.running = False
        self.worker.join()
        self.fileobj.close()

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()


class ThreadedGzipWriter(io.RawIOBase):
    def __init__(self,
                 fp: BinaryIO,
                 level: int = isal_zlib.ISAL_DEFAULT_COMPRESSION,
                 threads: int = 1,
                 queue_size: int = 2):
        self.raw = fp
        self.level = level
        self.previous_block = b""
        self.input_queues: List[queue.Queue[Tuple[bytes, memoryview]]] = [
            queue.Queue(queue_size) for _ in range(threads)]
        self.output_queues: List[queue.Queue[Tuple[bytes, int, int]]] = [
            queue.Queue(queue_size) for _ in range(threads)]
        self.index = 0
        self.threads = threads
        self._crc = 0
        self.running = False
        self._size = 0
        self.output_worker = threading.Thread(target=self._write)
        self.compression_workers = [
            threading.Thread(target=self._compress, args=(i,))
            for i in range(threads)
        ]
        self._closed = False
        self._write_gzip_header()
        self.start()

    def _write_gzip_header(self):
        """Simple gzip header. Only xfl flag is set according to level."""
        magic1 = 0x1f
        magic2 = 0x8b
        method = 0x08
        flags = 0
        mtime = 0
        os = 0xff
        xfl = 4 if self.level == 0 else 0
        self.raw.write(struct.pack(
            "BBBBIBB", magic1, magic2, method, flags, mtime, os, xfl))

    def start(self):
        self.running = True
        self.output_worker.start()
        for worker in self.compression_workers:
            worker.start()

    def stop_immediately(self):
        """Stop, but do not care for remaining work"""
        self.running = False
        self.output_worker.join()
        for worker in self.compression_workers:
            worker.join()

    def write(self, b) -> int:
        if self._closed:
            raise IOError("Can not write closed file")
        index = self.index
        data = bytes(b)
        zdict = memoryview(self.previous_block)[-DEFLATE_WINDOW_SIZE:]
        self.previous_block = data
        self.index += 1
        worker_index = index % self.threads
        self.input_queues[worker_index].put((data, zdict))
        return len(data)

    def flush(self):
        if self._closed:
            raise IOError("Can not write closed file")
        # Wait for all data to be compressed
        for in_q in self.input_queues:
            in_q.join()
        # Wait for all data to be written
        for out_q in self.output_queues:
            out_q.join()
        self.raw.flush()

    def close(self) -> None:
        self.flush()
        self.stop_immediately()
        # Write an empty deflate block with a lost block marker.
        self.raw.write(isal_zlib.compress(b"", wbits=-15))
        trailer = struct.pack("<II", self._crc, self._size & 0xFFFFFFFF)
        self.raw.write(trailer)
        self.raw.flush()
        self.raw.close()
        self._closed = True

    @property
    def closed(self) -> bool:
        return self._closed

    def _compress(self, index: int):
        in_queue = self.input_queues[index]
        out_queue = self.output_queues[index]
        while self.running:
            try:
                data, zdict = in_queue.get(timeout=0.05)
            except queue.Empty:
                continue
            compressor = isal_zlib.compressobj(
                self.level, wbits=-15, zdict=zdict)
            compressed = compressor.compress(data) + compressor.flush(
                isal_zlib.Z_SYNC_FLUSH)
            crc = isal_zlib.crc32(data)
            data_length = len(data)
            out_queue.put((compressed, crc, data_length))
            in_queue.task_done()

    def _write(self):
        index = 0
        output_queues = self.output_queues
        fp = self.raw
        total_crc = 0
        size = 0
        while self.running:
            out_index = index % self.threads
            output_queue = output_queues[out_index]
            try:
                compressed, crc, data_length = output_queue.get(timeout=0.05)
            except queue.Empty:
                continue
            total_crc = isal_zlib.crc32_combine(total_crc, crc, data_length)
            size += data_length
            fp.write(compressed)
            output_queue.task_done()
            index += 1
        self._crc = total_crc
        self._size = size

    def writable(self) -> bool:
        return True

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()
