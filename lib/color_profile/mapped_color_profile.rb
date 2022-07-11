require_relative '../color_profile.rb'

class MappedColorProfile < ColorProfile
  def to_png(eight_bit_ir_tokens)
    eight_bit_ir_tokens.map do |eb_ir_token|
      local_color_map.get!(eb_ir_token)
    end
  end

  def from_png(png_triples)
    png_triples.map do |triple| 
      local_color_map.backward_get!(triple)
    end
  end

  def start_color
    raise NotImplementedError
  end

  def end_color
    raise NotImplementedError
  end

  private

  def local_color_map
    @_ocm ||= begin
      color_map(start_color, end_color)
    end
  end
end

class BrownColorProfile < MappedColorProfile
  def start_color; [51, 21, 0]; end
  def end_color; [255, 229, 204]; end
end

class YellowColorProfile < MappedColorProfile
  def start_color; [0, 0, 0]; end
  def end_color; [255, 255, 51]; end
end

# Dark purple
class PurpleColorProfile < MappedColorProfile
  def start_color; [25, 0, 51]; end
  def end_color; [229, 204, 255]; end
end

# dark aqua
class AquaColorProfile < MappedColorProfile
  def start_color; [0, 0, 0] ;end
  def end_color; [51, 255, 255] ;end
end


###### Not Added or Tested
class OrangeColorProfile < MappedColorProfile
  def start_color; [51, 25, 0]; end
  def end_color; [255, 153, 51]; end
end

class OrangeTwoColorProfile < MappedColorProfile
  def start_color; [153, 76, 0]; end
  def end_color; [255, 229, 204]; end
end

class YellowTwoColorProfile < MappedColorProfile
  def start_color; [204, 204, 0]; end
  def end_color; [255, 255, 204]; end
end

class PurpleTwoColorProfile < MappedColorProfile
  def start_color; [76, 0, 153]; end
  def end_color; [229, 204, 255]; end
end

class GreenTwoColorProfile < MappedColorProfile
  def start_color; [0, 51, 0] ;end
  def end_color; [51, 255, 51] ;end
end

# Light Green
class GreenThreeColorProfile < MappedColorProfile
  def start_color; [0, 204, 102]; end
  def end_color; [205, 255, 229]; end
end

class AquaTwoColorProfile < MappedColorProfile
  def start_color; [0, 204, 204] ;end
  def end_color; [204, 255, 255] ;end
end

# Dark PP
class PinkPurpleColorProfile < MappedColorProfile
  def start_color; [51, 0, 51] ;end
  def end_color; [255, 51, 255] ;end
end
