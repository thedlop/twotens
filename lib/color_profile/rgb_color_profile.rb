require_relative '../color_profile.rb'
class RgbColorProfile < ColorProfile
  # params: Array(int)
  def to_png(ir_tokens)
    png_triples = []
    ir_tokens.each_slice(3) do |slice|
      red = slice[0]
      green = slice[1] || 0
      blue = slice[2] || 0
      png_triple = [red, green, blue]
      png_triples.push(png_triple)
    end
    png_triples
  end

  def from_png(png_triples)
    png_triples.flatten
  end
end

