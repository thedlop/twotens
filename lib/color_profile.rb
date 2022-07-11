require_relative 'dir_walker'

class ColorProfile
  # params: Array(int)
  def to_png(ir_tokens)
    raise NotImplementedError
  end

  def from_png(png_truples)
    raise NotImplementedError
  end

  def color_map(start_color, end_color)
    h = UniqueTwoWayHash.new
    increment_count = 255.0

    increment_r = (end_color[0] - start_color[0]) / increment_count 
    increment_g = (end_color[1] - start_color[1]) / increment_count 
    increment_b = (end_color[2] - start_color[2]) / increment_count 

    previous = start_color
    h.merge!({0 => start_color})
    255.times do |i|
      current = previous.dup
      current[0] = [(current[0] + increment_r).round, 255].min
      current[1] = [(current[1] + increment_g).round, 255].min
      current[2] = [(current[2] + increment_b).round, 255].min
      h.merge!({ i + 1 => current }) 
      previous = current
    end
    h
  end
end
