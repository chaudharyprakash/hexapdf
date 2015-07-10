# -*- encoding: utf-8 -*-

require 'test_helper'
require 'hexapdf/pdf/filter/encryption'

describe HexaPDF::PDF::Filter::Encryption do
  before do
    @obj = HexaPDF::PDF::Filter::Encryption
  end

  it "returns the correct decryption fiber" do
    algorithm = Minitest::Mock.new
    algorithm.expect(:decryption_fiber, :fiber, [:key, :source])
    assert_equal(:fiber, @obj.decoder(:source, key: :key, algorithm: algorithm))
    algorithm.verify
  end

  it "returns the correct encryption fiber" do
    algorithm = Minitest::Mock.new
    algorithm.expect(:encryption_fiber, :fiber, [:key, :source])
    assert_equal(:fiber, @obj.encoder(:source, key: :key, algorithm: algorithm))
    algorithm.verify
  end
end
