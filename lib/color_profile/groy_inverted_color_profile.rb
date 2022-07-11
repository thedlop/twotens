require_relative '../color_profile.rb'
class GrayInvertedColorProfile < ColorProfile
  # params: Array(int)
  def to_png(ir_tokens)
    ir_tokens.map do |ir_token|
      inverted = (irtoken + 255).abs
      [ir_token, ir_token, ir_token]
    end
  end

  def from_png(png_triples)
    png_triples.map do |triple| 
      (triple[0] - 255).abs
    end
  end
end
