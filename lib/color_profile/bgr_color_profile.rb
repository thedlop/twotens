require_relative '../color_profile.rb'
class BgrColorProfile < ColorProfile
  # params: Array(int)
  def to_png(ir_tokens)
    png_triples = []
    ir_tokens.each_slice(3) do |slice|
      png_triple = [slice[0], slice[1] || 0, slice[2] || 0].reverse
      png_triples.push(png_triple)
    end
    png_triples
  end

  def from_png(png_triples)
    from = []
    png_triples.each do |(b,g,r)|
      from.push([r,g,b])
    end
    from.flatten
  end
end

