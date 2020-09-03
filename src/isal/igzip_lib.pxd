# Copyright (c) 2020 Leiden University Medical Center
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# cython: language_level=3

cdef extern from "<isa-l/igzip_lib.h>":
    # Deflate compression standard defines
    int ISAL_DEF_MAX_HDR_SIZE
    int ISAL_DEF_MAX_CODE_LEN
    int IGZIP_K
    int ISAL_DEF_HIST_SIZE
    int ISAL_DEF_MAX_HIST_BITS
    int ISAL_DEF_MAX_MATCH
    int ISAL_DEF_MIN_MATCH

    int ISAL_DEF_LIT_SYMBOLS
    int ISAL_DEF_LEN_SYMBOLS
    int ISAL_DEF_DIST_SYMBOLS
    int ISAL_DEF_LIT_LEN_SYMBOLS

    # Deflate Implementation Specific Define
    int IGZIP_HIST_SIZE

    # Max repeat length
    int ISAL_LOOK_AHEAD

    # Flush flags
    int NO_FLUSH  # Defaults
    int SYNC_FLUSH
    int FULL_FLUSH
    int FINISH_FLUSH

    # Gzip flags
    int IGZIP_DEFLATE  # Default
    int IGZIP_GZIP
    int IGZIP_GZIP_NO_HDR
    int IGZIP_ZLIB
    int IGZIP_ZLIB_NO_HDR

    # Compression return values
    int COMP_OK 
    int INVALID_FLUSH
    int INVALID_PARAM
    int STATELESS_OVERFLOW
    int ISAL_INVALID_OPERATION
    int ISAL_INVALID_STATE 
    int ISAL_INVALID_LEVEL 
    int ISAL_INVALID_LEVEL_BUF

    cdef enum isal_zstate_state:
        ZSTATE_NEW_HDR  #!< Header to be written
        ZSTATE_HDR,  #!< Header state
        ZSTATE_CREATE_HDR  #!< Header to be created
        ZSTATE_BODY,  #!< Body state
        ZSTATE_FLUSH_READ_BUFFER  #!< Flush buffer
        ZSTATE_FLUSH_ICF_BUFFER
        ZSTATE_TYPE0_HDR  #! Type0 block header to be written
        ZSTATE_TYPE0_BODY  #!< Type0 block body to be written
        ZSTATE_SYNC_FLUSH  #!< Write sync flush block
        ZSTATE_FLUSH_WRITE_BUFFER  #!< Flush bitbuf
        ZSTATE_TRL,  #!< Trailer state
        ZSTATE_END,  #!< End state
        ZSTATE_TMP_NEW_HDR  #!< Temporary Header to be written
        ZSTATE_TMP_HDR,  #!< Temporary Header state
        ZSTATE_TMP_CREATE_HDR  #!< Temporary Header to be created state
        ZSTATE_TMP_BODY  #!< Temporary Body state
        ZSTATE_TMP_FLUSH_READ_BUFFER  #!< Flush buffer
        ZSTATE_TMP_FLUSH_ICF_BUFFER
        ZSTATE_TMP_TYPE0_HDR  #! Temporary Type0 block header to be written
        ZSTATE_TMP_TYPE0_BODY  #!< Temporary Type0 block body to be written
        ZSTATE_TMP_SYNC_FLUSH  #!< Write sync flush block
        ZSTATE_TMP_FLUSH_WRITE_BUFFER  #!< Flush bitbuf
        ZSTATE_TMP_TRL   #!< Temporary Trailer state
        ZSTATE_TMP_END  #!< Temporary End state

    cdef enum isal_block_state:
        ISAL_BLOCK_NEW_HDR,  # Just starting a new block */
        ISAL_BLOCK_HDR,    # In the middle of reading in a block header */
        ISAL_BLOCK_TYPE0,  # Decoding a type 0 block */
        ISAL_BLOCK_CODED,  # Decoding a huffman coded block */
        ISAL_BLOCK_INPUT_DONE,  # Decompression of input is completed */
        ISAL_BLOCK_FINISH,  # Decompression of input is completed and all data has been flushed to output */
        ISAL_GZIP_EXTRA_LEN,
        ISAL_GZIP_EXTRA,
        ISAL_GZIP_NAME,
        ISAL_GZIP_COMMENT,
        ISAL_GZIP_HCRC,
        ISAL_ZLIB_DICT,
        ISAL_CHECKSUM_CHECK,
    
    # Inflate flags
    int ISAL_DEFLATE 
    int ISAL_GZIP 
    int ISAL_GZIP_NO_HDR
    int ISAL_ZLIB
    int ISAL_ZLIB_NO_HDR
    int ISAL_ZLIB_NO_HDR_VER
    int ISAL_GZIP_NO_HDR_VER

    # Inflate return values
    int ISAL_DECOMP_OK
    int ISAL_END_INPUT
    int ISAL_OUT_OVERFLOW
    int ISAL_NAME_OVERFLOW
    int ISAL_COMMENT_OVERFLOW
    int ISAL_EXTRA_OVERFLOW
    int ISAL_NEED_DICT
    int ISAL_INVALID_BLOCK
    int ISAL_INVALID_LOOKBACK
    int ISAL_INVALID_WRAPPER
    int ISAL_UNSOPPERTED_METHOD
    int ISAL_INCORRECT_CHECKSUM

    # Compression structures
    int ISAL_DEF_MIN_LEVEL
    int ISAL_DEF_MAX_LEVEL

    int ISAL_DEF_LVL0_MIN
    int ISAL_DEF_LVL0_SMALL
    int ISAL_DEF_LVL0_MEDIUM
    int ISAL_DEF_LVL0_LARGE
    int ISAL_DEF_LVL0_EXTRA_LARGE
    int ISAL_DEF_LVL0_DEFAULT

    int ISAL_DEF_LVL1_MIN
    int ISAL_DEF_LVL1_SMALL
    int ISAL_DEF_LVL1_MEDIUM
    int ISAL_DEF_LVL1_LARGE
    int ISAL_DEF_LVL1_EXTRA_LARGE
    int ISAL_DEF_LVL1_DEFAULT

    int ISAL_DEF_LVL2_MIN
    int ISAL_DEF_LVL2_SMALL
    int ISAL_DEF_LVL2_MEDIUM
    int ISAL_DEF_LVL2_LARGE
    int ISAL_DEF_LVL2_EXTRA_LARGE
    int ISAL_DEF_LVL2_DEFAULT

    int ISAL_DEF_LVL3_MIN
    int ISAL_DEF_LVL3_SMALL
    int ISAL_DEF_LVL3_MEDIUM
    int ISAL_DEF_LVL3_LARGE
    int ISAL_DEF_LVL3_EXTRA_LARGE
    int ISAL_DEF_LVL3_DEFAULT
    
    cdef struct BitBuf2:
        unsigned long long m_bits  #!< bits in the bit buffer
        unsigned long m_bits_count;  #!< number of valid bits in the bit buffer 
        unsigned char *m_out_buff  #!< current index of buffer to write to
        unsigned char *m_out_end  #!< end of buffer to write to
        unsigned char *m_out_start  #!< start of buffer to write to
    
    cdef struct isal_zstate:
        unsigned long total_in_start #!< Not used, may be replaced with something else
        unsigned long block_next  #!< Start of current deflate block in the input
        unsigned long block_end  #!< End of current deflate block in the input
        unsigned long dist_mask  #!< Distance mask used.
        unsigned long hash_mask
        isal_zstate_state state  #!< Current state in processing the data stream
        BitBuf2 bitbuf
        unsigned long crc  #!< Current checksum without finalize step if any (adler)
        unsigned char has_wrap_hdr  #!< keeps track of wrapper header
        unsigned char has_eob_hdr  #!< keeps track of eob on the last deflate block
        unsigned char has_hist  #!< flag to track if there is match history
        unsigned int has_level_buf_init  #!< flag to track if user supplied memory has been initialized.
        unsigned long count  #!< used for partial header/trailer writes
        unsigned char tmp_out_buff[16]  #! temporary array
        unsigned long tmp_out_start  #!< temporary variable
        unsigned long tmp_out_end  #!< temporary variable
        unsigned long b_bytes_valid  #!< number of valid bytes in buffer
        unsigned long b_bytes_processed  #!< number of bytes processed in buffer
        # Below values give compile errors because they are dynamic in size
        #unsigned char buffer[2 * IGZIP_HIST_SIZE + ISAL_LOOK_AHEAD]  #!< Internal buffer
            # Stream should be setup such that the head is cache aligned
        #unsigned int head[IGZIP_LVL0_HASH_SIZE]  #!< Hash array

    cdef struct isal_hufftables:
        pass

    cdef struct isal_zstream:
        unsigned char *next_in  #!< Next input byte
        unsigned long avail_in  #!< number of bytes available at next_in
        unsigned long total_in_start  #!< total number of bytes read so far
        unsigned char *next_out  #!< Next output byte
        unsigned long avail_out  #!< number of bytes available at next_out
        unsigned long total_out  #!< total number of bytes written so far
        isal_hufftables *hufftables  #!< Huffman encoding used when compressing
        unsigned long level  #!< Compression level to use
        unsigned long level_buf_size  #!< Size of level_buf
        unsigned char * level_buf  #!< User allocated buffer required for different compression levels
        unsigned int end_of_stream  #!< non-zero if this is the last input buffer
        unsigned int flush  #!< Flush type can be NO_FLUSH, SYNC_FLUSH or FULL_FLUSH
        unsigned int gzip_flag  #!< Indicate if gzip compression is to be performed
        unsigned int hist_bits  #!< Log base 2 of maximum lookback distance, 0 is use default
        isal_zstate internal_state  #!< Internal state for this stream

    # Inflate structures
    cdef struct inflate_huff_code_large:
        pass
    cdef struct inflate_huff_code_small:
        pass

    cdef struct inflate_state:
        unsigned char *next_out  #!< Next output byte
        unsigned long avail_out  #!< number of bytes available at next_out
        unsigned long total_out  #!< total number of bytes written so far
        unsigned char *next_in  #!< Next input byte
        unsigned long avail_in  #!< number of bytes available at next_in
        unsigned long total_in_start  #!< total number of bytes read so far      
        long read_in_length  #!< Bits in read_in
        inflate_huff_code_large  lit_huff_code
        inflate_huff_code_small  dist_huff_code
        isal_block_state block_state
        unsigned long dict_length
        unsigned long bfinal
        unsigned long crc_flag
        unsigned long crc
        unsigned long hist_bits
        # Other members are omitted because they are not in use yet.

    # Compression functions
    # /**
    #  * @brief Initialize compression stream data structure
    #  *
    #  * @param stream Structure holding state information on the compression streams.
    #  * @returns none
    #  */
    cdef void isal_deflate_init(isal_zstream *stream)
    #/**
    #  * @brief Initialize compression stream data structure
    #  *
    #  * @param stream Structure holding state information on the compression streams.
    #  * @returns none
    #  */
    cdef void isal_deflate_stateless_init(isal_zstream *stream)

    #  /**
    #  * @brief Set compression dictionary to use
    #  *
    #  * This function is to be called after isal_deflate_init, or after completing a
    #  * SYNC_FLUSH or FULL_FLUSH and before the next call do isal_deflate. If the
    #  * dictionary is longer than IGZIP_HIST_SIZE, only the last IGZIP_HIST_SIZE
    #  * bytes will be used.
    #  *
    #  * @param stream Structure holding state information on the compression streams.
    #  * @param dict: Array containing dictionary to use.
    #  * @param dict_len: Length of dict.
    #  * @returns COMP_OK,
    #  *          ISAL_INVALID_STATE (dictionary could not be set)
    #  */
    cdef int isal_deflate_set_dict(isal_zstream *stream, 
                                   unsigned char *dict,
                                   unsigned long dict_len )


    #/**
    #  * @brief Fast data (deflate) compression for storage applications.
    #  *
    #  * The call to isal_deflate() will take data from the input buffer (updating
    #  * next_in, avail_in and write a compressed stream to the output buffer
    #  * (updating next_out and avail_out). The function returns when either the input
    #  * buffer is empty or the output buffer is full.
    #  *
    #  * On entry to isal_deflate(), next_in points to an input buffer and avail_in
    #  * indicates the length of that buffer. Similarly next_out points to an empty
    #  * output buffer and avail_out indicates the size of that buffer.
    #  *
    #  * The fields total_in and total_out start at 0 and are updated by
    #  * isal_deflate(). These reflect the total number of bytes read or written so far.
    #  *
    #  * When the last input buffer is passed in, signaled by setting the
    #  * end_of_stream, the routine will complete compression at the end of the input
    #  * buffer, as long as the output buffer is big enough.
    #  *
    #  * The compression level can be set by setting level to any value between
    #  * ISAL_DEF_MIN_LEVEL and ISAL_DEF_MAX_LEVEL. When the compression level is
    #  * ISAL_DEF_MIN_LEVEL, hufftables can be set to a table trained for the the
    #  * specific data type being compressed to achieve better compression. When a
    #  * higher compression level is desired, a larger generic memory buffer needs to
    #  * be supplied by setting level_buf and level_buf_size to represent the chunk of
    #  * memory. For level x, the suggest size for this buffer this buffer is
    #  * ISAL_DEFL_LVLx_DEFAULT. The defines ISAL_DEFL_LVLx_MIN, ISAL_DEFL_LVLx_SMALL,
    #  * ISAL_DEFL_LVLx_MEDIUM, ISAL_DEFL_LVLx_LARGE, and ISAL_DEFL_LVLx_EXTRA_LARGE
    #  * are also provided as other suggested sizes.
    #  *
    #  * The equivalent of the zlib FLUSH_SYNC operation is currently supported.
    #  * Flush types can be NO_FLUSH, SYNC_FLUSH or FULL_FLUSH. Default flush type is
    #  * NO_FLUSH. A SYNC_ OR FULL_ flush will byte align the deflate block by
    #  * appending an empty stored block once all input has been compressed, including
    #  * the buffered input. Checking that the out_buffer is not empty or that
    #  * internal_state.state = ZSTATE_NEW_HDR is sufficient to guarantee all input
    #  * has been flushed. Additionally FULL_FLUSH will ensure look back history does
    #  * not include previous blocks so new blocks are fully independent. Switching
    #  * between flush types is supported.
    #  *
    #  * If a compression dictionary is required, the dictionary can be set calling
    #  * isal_deflate_set_dictionary before calling isal_deflate.
    #  *
    #  * If the gzip_flag is set to IGZIP_GZIP, a generic gzip header and the gzip
    #  * trailer are written around the deflate compressed data. If gzip_flag is set
    #  * to IGZIP_GZIP_NO_HDR, then only the gzip trailer is written. A full-featured
    #  * header is supported by the isal_write_{gzip,zlib}_header() functions.
    #  *
    #  * @param  stream Structure holding state information on the compression streams.
    #  * @return COMP_OK (if everything is ok),
    #  *         INVALID_FLUSH (if an invalid FLUSH is selected),
    #  *         ISAL_INVALID_LEVEL (if an invalid compression level is selected),
    #  *         ISAL_INVALID_LEVEL_BUF (if the level buffer is not large enough).
    #  */
    cdef int isal_deflate(isal_zstream *stream)

    #/**
    #  * @brief Fast data (deflate) stateless compression for storage applications.
    #  *
    #  * Stateless (one shot) compression routine with a similar interface to
    #  * isal_deflate() but operates on entire input buffer at one time. Parameter
    #  * avail_out must be large enough to fit the entire compressed output. Max
    #  * expansion is limited to the input size plus the header size of a stored/raw
    #  * block.
    #  *
    #  * When the compression level is set to 1, unlike in isal_deflate(), level_buf
    #  * may be optionally set depending on what what performance is desired.
    #  *
    #  * For stateless the flush types NO_FLUSH and FULL_FLUSH are supported.
    #  * FULL_FLUSH will byte align the output deflate block so additional blocks can
    #  * be easily appended.
    #  *
    #  * If the gzip_flag is set to IGZIP_GZIP, a generic gzip header and the gzip
    #  * trailer are written around the deflate compressed data. If gzip_flag is set
    #  * to IGZIP_GZIP_NO_HDR, then only the gzip trailer is written.
    #  *
    #  * @param  stream Structure holding state information on the compression streams.
    #  * @return COMP_OK (if everything is ok),
    #  *         INVALID_FLUSH (if an invalid FLUSH is selected),
    #  *         ISAL_INVALID_LEVEL (if an invalid compression level is selected),
    #  *         ISAL_INVALID_LEVEL_BUF (if the level buffer is not large enough),
    #  *         STATELESS_OVERFLOW (if output buffer will not fit output).
    #  */
    cdef int isal_deflate_stateless(isal_zstream *stream)

    # Other functions

    #     /**
    #  * @brief Calculate Adler-32 checksum, runs appropriate version.
    #  *
    #  * This function determines what instruction sets are enabled and selects the
    #  * appropriate version at runtime.
    #  *
    #  * @param init: initial Adler-32 value
    #  * @param buf: buffer to calculate checksum on
    #  * @param len: buffer length in bytes
    #  *
    #  * @returns 32-bit Adler-32 checksum
    #  */

    unsigned long isal_adler32(unsigned long init, 
                               const unsigned char *buf, 
                               unsigned long long len)

    ###########################
    # Inflate functions
    ###########################
    # /**
    #  * @brief Initialize decompression state data structure
    #  *
    #  * @param state Structure holding state information on the compression streams.
    #  * @returns none
    #  */
    void isal_inflate_init(struct inflate_state *state)

    # /**
    #  * @brief Reinitialize decompression state data structure
    #  *
    #  * @param state Structure holding state information on the compression streams.
    #  * @returns none
    #  */
    void isal_inflate_reset(struct inflate_state *state)

    # /**
    #  * @brief Set decompression dictionary to use
    #  *
    #  * This function is to be called after isal_inflate_init. If the dictionary is
    #  * longer than IGZIP_HIST_SIZE, only the last IGZIP_HIST_SIZE bytes will be
    #  * used.
    #  *
    #  * @param state: Structure holding state information on the decompression stream.
    #  * @param dict: Array containing dictionary to use.
    #  * @param dict_len: Length of dict.
    #  * @returns COMP_OK,
    #  *          ISAL_INVALID_STATE (dictionary could not be set)
    #  */
    int isal_inflate_set_dict(inflate_state *state, unsigned char *dict, unsigned long dict_len)

    # /**
    #  * @brief Fast data (deflate) decompression for storage applications.
    #  *
    #  * On entry to isal_inflate(), next_in points to an input buffer and avail_in
    #  * indicates the length of that buffer. Similarly next_out points to an empty
    #  * output buffer and avail_out indicates the size of that buffer.
    #  *
    #  * The field total_out starts at 0 and is updated by isal_inflate(). This
    #  * reflects the total number of bytes written so far.
    #  *
    #  * The call to isal_inflate() will take data from the input buffer (updating
    #  * next_in, avail_in and write a decompressed stream to the output buffer
    #  * (updating next_out and avail_out). The function returns when the input buffer
    #  * is empty, the output buffer is full, invalid data is found, or in the case of
    #  * zlib formatted data if a dictionary is specified. The current state of the
    #  * decompression on exit can be read from state->block-state.
    #  *
    #  * If the crc_flag is set to ISAL_GZIP_NO_HDR the gzip crc of the output is
    #  * stored in state->crc. Alternatively, if the crc_flag is set to
    #  * ISAL_ZLIB_NO_HDR the adler32 of the output is stored in state->crc (checksum
    #  * may not be updated until decompression is complete). When the crc_flag is set
    #  * to ISAL_GZIP_NO_HDR_VER or ISAL_ZLIB_NO_HDR_VER, the behavior is the same,
    #  * except the checksum is verified with the checksum after immediately following
    #  * the deflate data. If the crc_flag is set to ISAL_GZIP or ISAL_ZLIB, the
    #  * gzip/zlib header is parsed, state->crc is set to the appropriate checksum,
    #  * and the checksum is verified. If the crc_flag is set to ISAL_DEFLATE
    #  * (default), then the data is treated as a raw deflate block.
    #  *
    #  * The element state->hist_bits has values from 0 to 15, where values of 1 to 15
    #  * are the log base 2 size of the matching window and 0 is the default with
    #  * maximum history size.
    #  *
    #  * If a dictionary is required, a call to isal_inflate_set_dict will set the
    #  * dictionary.
    #  *
    #  * @param  state Structure holding state information on the compression streams.
    #  * @return ISAL_DECOMP_OK (if everything is ok),
    #  *         ISAL_INVALID_BLOCK,
    #  *         ISAL_NEED_DICT,
    #  *         ISAL_INVALID_SYMBOL,
    #  *         ISAL_INVALID_LOOKBACK,
    #  *         ISAL_INVALID_WRAPPER,
    #  *         ISAL_UNSUPPORTED_METHOD,
    #  *         ISAL_INCORRECT_CHECKSUM.
    #  */
    int isal_inflate(struct inflate_state *state)
