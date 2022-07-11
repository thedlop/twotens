require_relative './unique_two_way_hash.rb'
require_relative './utils.rb'

class TensSectionDependent
  # name: symbol
  # data: array(any)
  attr_accessor :name, :data

  def initialize(name, data: [])
    @name = name
    @data = data
  end

  INTERNAL_START_TOKEN = :internal_dependent_start
  INTERNAL_END_TOKEN = :internal_dependent_end

  def self.internal_tokens
    [INTERNAL_START_TOKEN, INTERNAL_END_TOKEN]
  end

  def internal_tokens
    self.class.internal_tokens
  end

  def tokens
    internal_tokens + data
  end

  # token_colors: UniqueTwoWayHash
  # returns [Chunky::PNG (ints), ...]
  def encode(token_colors)
    encoded = []

    encoded << token_colors.get!(INTERNAL_START_TOKEN)
    data.each do |token|
      encoded << token_colors.get!(token)
    end
    encoded << token_colors.get!(INTERNAL_END_TOKEN)
  end

  def decode_with_tokens!(tokens)
    token = tokens.shift
    Utils.assert_equals(token, INTERNAL_START_TOKEN)
    new_data = []
    loop do
      token = tokens.shift
      break if INTERNAL_END_TOKEN == token
      new_data.push(token)
    end

    self.data = new_data
    # decoded
    tokens 
  end

  # name: string
  # data: array(any)
  # token_colors: UniqueTwoWayHash
  # output_colors, array(Chunky::PNG (ints))
  # return
  # [TensSectionDependent, output_colors]
  def self.decode(name, token_colors, output_colors)
    ts = TensSectionDependent.new(name, data: [])
    token = token_colors.backward_get!(output_colors.shift)
    Utils.assert_equals(token, INTERNAL_START_TOKEN)
    loop do
      token = token_colors.backward_get!(output_colors.shift)
      break if INTERNAL_END_TOKEN == token
      ts.data.push(token)
    end
    # decoded
    [ts, output_colors]
  end
end
