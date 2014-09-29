# -*- encoding: utf-8 -*-

require 'hexapdf/pdf/parser'
require 'hexapdf/pdf/object_store'
require 'hexapdf/pdf/pdf_object'
require 'hexapdf/configuration'

module HexaPDF
  module PDF

    # A PDF document.
    class Document

      attr_reader :config

      def self.from_io(io, config = HexaPDF::Configuration.new)
        parser = Parser.new(io, config)
        ostore = ObjectStore.new(parser.xref_table)
        self.new(config, ostore)
      end

      def initialize(config = HexaPDF::Configuration.new)
        @config = config
        @store  = ObjectStore.new(self)
      end

      def deref(obj)
        @store.deref(obj)
      end

    end

  end
end