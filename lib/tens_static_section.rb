require_relative './utils.rb'
require_relative './unique_two_way_hash.rb'

class TensStaticSection
  attr_accessor :name, :token_colors

  def initialize(name, token_colors)
    @name = name
    @token_colors = UniqueTwoWayHash.new(token_colors)
  end

  # returns [Chunky::PNG (ints), ...]
  def encode(data)
    data.map do |d|
      @token_colors.get!(d)
    end
  end

  # colors: array(int)
  # returns
  # [ decoded data, modified colors ] 
  # [ array(any), array(int) ]
  def decode(colors)
    colors.map do |color|
      @token_colors.backward_get!(color)
    end
  end
end
