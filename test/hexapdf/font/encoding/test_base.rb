# -*- encoding: utf-8 -*-

require 'test_helper'
require 'hexapdf/font/encoding/base'

describe HexaPDF::Font::Encoding::Base do
  before do
    @base = HexaPDF::Font::Encoding::Base.new
    @base.code_to_name[65] = :A
  end

  it "returns nil for the encoding_name" do
    assert_nil(@base.encoding_name)
  end

  describe "name" do
    it "returns a mapped code" do
      assert_equal(:A, @base.name(65))
    end

    it "returns .notdef for an unmapped code" do
      assert_equal(:'.notdef', @base.name(66))
    end
  end

  describe "unicode" do
    it "returns the unicode value of the code" do
      assert_equal("A", @base.unicode(65))
    end

    it "returns an empty string for an unmapped code" do
      assert_equal('', @base.unicode(66))
    end
  end
end
