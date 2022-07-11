require_relative '../color_profile.rb'
class RedColorProfile < ColorProfile
  # params: Array(int)
  def to_png(ir_tokens)
    ir_tokens.map do |ir_token|
      [ir_token, 0, 0]
    end
  end

  def from_png(png_triples)
    png_triples.map do |triple| 
      triple[0]
    end
  end
end

