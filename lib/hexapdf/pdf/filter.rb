# -*- encoding: utf-8 -*-

require 'fiber'
require 'hexapdf/filter/ascii_hex_decode'
require 'hexapdf/filter/ascii85_decode'
require 'hexapdf/filter/lzw_decode'
require 'hexapdf/filter/run_length_decode'
require 'hexapdf/filter/dct_decode'
require 'hexapdf/filter/jpx_decode'

module HexaPDF
  module PDF

    # This class manages implementations of supported filters.
    #
    #
    # == Overview
    #
    # A *stream filter* is used to compress a stream or to encode it in an ASCII compatible way; or
    # to reverse this process. Some filters can be used for any content, like FlateDecode, others
    # are specifically designed for image streams, like DCTDecode.
    #
    # Each filter is implemented via fibers. This allows HexaPDF to easily process either small
    # chunks or a whole stream at once, depending on the memory restrictions.
    #
    # It also allows the easy re-processing of a stream without first decoding and the encoding it.
    # Such functionality is useful, for example, when a PDF file should decrypted and streams
    # compressed in one step.
    #
    #
    # == Implementation of a Filter Module
    #
    # Each filter is an object (normally a module) that responds to two methods: #encoder and
    # #decoder. Both of these methods are given a *source* (a Fiber) and *options* (a Hash) and have
    # to return a Fiber object.
    #
    # The returned fiber should resume the *source* fiber to get the next chunk of data (possibly
    # only one byte of data, so this situation should be handled gracefully). Once the fiber has
    # processed this chunk, it should yield the processed chunk as binary string. This should be
    # done as long as the source fiber is #alive? and doesn't return +nil+ when resumed.
    #
    # See: PDF1.7 7.4
    class Filter

      def initialize(config)
        @config = config
      end

      def encoder(name, options)
        filter = @config['hexapdf.filter.map'][name]
        if filter
          filter.encoder(
      end

      def decoder_chain
      end

    end

  end
end