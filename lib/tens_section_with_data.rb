require_relative './unique_two_way_hash.rb'

class TensSectionWithData
  # name, symbol
  # data, array(any)
  # internal_tokens, array(any)
  attr_accessor :name, :data, :data_ir_map, :internal_tokens

  def initialize(name, data, ir_tokens: nil, internal_tokens: [])
    @name = name
    @data = data
    @data_ir_map = UniqueTwoWayHash.new
    @internal_tokens = internal_tokens
    final_ir_tokens = ir_tokens || default_ir_tokens
    build_token_ir_map(final_ir_tokens)
  end

  def build_token_ir_map(ir_tokens)
    tokens.each.with_index do |token,idx|
      @data_ir_map.merge!({token => ir_tokens[idx]})
    end
  end

  def default_ir_tokens
    (0..tokens.length-1).to_a
  end

  def tokens
    internal_tokens + data
  end

  def encode
    tokens.map do |token|
      @data_ir_map.get!(token)
    end
  end

  # name, string
  # data, array(any)
  # ir_tokens: array(ints)
  # returns
  # [TensSectionWithData, array(ints) ]
  def self.decode(name, data, ir_tokens, internal_tokens: [])
    ts = TensSectionWithData.new(name, data, internal_tokens: internal_tokens)
    [ts, ir_tokens]
  end
end
