require_relative '../color_profile.rb'
class GrayInvertedColorProfile < ColorProfile
  # params: Array(int)
  def to_png(ir_tokens)
    ir_tokens.map do |ir_token|
      inverted = (255 - ir_token).abs
      [inverted, inverted, inverted]
    end
  end

  def from_png(png_triples)
    png_triples.map do |triple| 
      (255 - triple[0]).abs
    end
  end
end
