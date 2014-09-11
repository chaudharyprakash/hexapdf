# -*- encoding: utf-8 -*-

require 'fiber'
require 'hexapdf/pdf/utils/bit_stream'

module HexaPDF
  module PDF
    module Filter

      # See: PDF1.7 7.4.4
      module LZWDecode

        CLEAR_TABLE = 256
        EOD = 257

        INITIAL_ENCODER_TABLE = {}
        0.upto(255) {|i| INITIAL_ENCODER_TABLE[i.chr] = i}
        INITIAL_ENCODER_TABLE[CLEAR_TABLE] = CLEAR_TABLE
        INITIAL_ENCODER_TABLE[EOD] = EOD

        INITIAL_DECODER_TABLE = {}
        0.upto(255) {|i| INITIAL_DECODER_TABLE[i] = i.chr}
        INITIAL_DECODER_TABLE[CLEAR_TABLE] = CLEAR_TABLE
        INITIAL_DECODER_TABLE[EOD] = EOD

        #TODO: implement predictor for lzw/flate

        def self.decoder(source, options = nil)
          Fiber.new do
            # initialize decoder state
            code_length = 9
            table = INITIAL_DECODER_TABLE.dup

            stream = HexaPDF::PDF::Utils::BitStreamReader.new
            result = ''.force_encoding('BINARY')
            finished = false
            last_code = CLEAR_TABLE

            while !finished && source.alive? && (data = source.resume)
              stream.append_data(data)

              while stream.read?(code_length)
                code = stream.read(code_length)

                # Decoder is one step behind => subtract 1!
                # We check the table size before entering the next code into it => subtract 1, but
                # there is one exception: After table entry 4095 is written, the clear table code
                # also gets written with code length 12,
                case table.size
                when 510, 1022, 2046
                  code_length += 1
                when 4095
                  if code != CLEAR_TABLE
                    raise "Maximum of 12bit for codes exceeded"
                  end
                end

                if code == EOD
                  finished = true
                  break
                elsif code == CLEAR_TABLE
                  # reset decoder state
                  code_length = 9
                  table = INITIAL_DECODER_TABLE.dup
                elsif last_code == CLEAR_TABLE
                  raise "Unknown code found" unless table.has_key?(code)
                  result << table[code]
                else
                  raise "Unknown code found" unless table.has_key?(last_code)
                  last_str = table[last_code]

                  str = if table.has_key?(code)
                          table[code]
                        else
                          last_str + last_str[0]
                        end
                  result << str
                  table[table.size] = last_str + str[0]
                end

                last_code = code
              end

              Fiber.yield(result)
              result = ''.force_encoding('BINARY')
            end

          end
        end

        def self.encoder(source, options = nil)
          Fiber.new do
            # initialize encoder state
            code_length = 9
            table = INITIAL_ENCODER_TABLE.dup

            # initialize the bit stream with the clear-table marker
            stream = HexaPDF::PDF::Utils::BitStreamWriter.new
            result = stream.write(CLEAR_TABLE, 9)
            str = ''.force_encoding('BINARY')

            while source.alive? && (data = source.resume)
              data.each_char do |char|
                newstr = str + char
                if table.has_key?(newstr)
                  str = newstr
                else
                  result << stream.write(table[str], code_length)
                  table[newstr] = table.size
                  str = char
                end

                case table.size
                when 512 then code_length = 10
                when 1024 then code_length = 11
                when 2048 then code_length = 12
                when 4096
                  result << stream.write(CLEAR_TABLE, code_length)
                  # reset encoder state
                  code_length = 9
                  table = INITIAL_ENCODER_TABLE.dup
                end
              end

              Fiber.yield(result)
              result = ''.force_encoding('BINARY')
            end

            result = stream.write(table[str], code_length)
            result << stream.write(EOD, code_length)
            result << stream.finalize

            result
          end
        end

      end

    end
  end
end