require_relative '../color_profile.rb'
class GreenColorProfile < ColorProfile
  # params: Array(int)
  def to_png(ir_tokens)
    ir_tokens.map do |ir_token|
      [0, ir_token, 0]
    end
  end

  def from_png(png_triples)
    png_triples.map do |triple| 
      triple[1]
    end
  end
end


