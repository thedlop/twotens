require_relative '../color_profile.rb'
class GrbColorProfile < ColorProfile
  # params: Array(int)
  def to_png(ir_tokens)
    png_triples = []
    ir_tokens.each_slice(3) do |slice|
      red = slice[0]
      green = slice[1] || 0
      blue = slice[2] || 0
      png_triple = [green, red, blue]
      png_triples.push(png_triple)
    end
    png_triples
  end

  def from_png(png_triples)
    from = []
    png_triples.each do |(g,r,b)|
      from.push([r,g,b])
    end
    from.flatten
  end
end

