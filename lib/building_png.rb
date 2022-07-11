require 'rubygems'
require 'bundler/setup'
require 'chunky_png'
require_relative 'utils.rb'

class BuildingPNG
  attr_accessor :png, :idx_x, :idx_y, :height, :width
  
  def initialize(width, height)
    @width = width
    @height = height
    @idx_x = 0
    @idx_y = 0
    @ridx_x = width - 1
    @ridx_y = height - 1
    @png = ChunkyPNG::Image.new(@width, @height, ChunkyPNG::Color::TRANSPARENT)
  end

  def self.from_file(filepath)
    png = ChunkyPNG::Image.from_file(filepath)
    bpng = BuildingPNG.new(png.width, png.height)
    bpng.png = png
    bpng.idx_x = png.width - 1 
    bpng.idx_y = png.height - 1 
    bpng
  end

  def save(filename, options = {})
    @png.save(filename, options)
  end

  def scale_until(width, height)
    modifier = 2
    scaled = nil
    until (!scaled.nil? && 
           scaled.width >= width && 
           scaled.height >= height) do

      scaled = scale(modifier)
      modifier += 1
    end

    scaled
  end

  # returns new bpng
  def scale(modifier)
    new_width = @png.width * modifier
    new_height = @png.height * modifier
    new_bpng = BuildingPNG.new(new_width, new_height)
    w_idx = 0
    h_idx = 0
    mx_idx = 0
    my_idx = 0
    times = 0
    until h_idx >= @png.height
      times += 1
      # modifier = 3
      # w_idx
      # 0 0 0 1 1 1
      # 0 0 0
      # 0 0 0
      next_color = @png[w_idx, h_idx]
      new_bpng.add_next_color(next_color)

      mx_idx += 1
      if(mx_idx == modifier)
        mx_idx = 0
        w_idx += 1
      end

      if(w_idx == @png.width)
        w_idx = 0
        my_idx += 1
      end

      if(my_idx == modifier)
        my_idx = 0
        h_idx += 1
      end
    end
    Utils.assert(new_bpng.done?)
    new_bpng
  end

  # color: ChunkyPNG::Color
  def add_next_color(color)
    raise PNGFullError if done?
    @png[@idx_x, @idx_y] = color
    @idx_x += 1
    if @idx_x >= @width
      @idx_x = 0
      @idx_y += 1
    end
    self
  end

  # Add colors from reverse direction, bottom right to the left
  def rev_add_next_color(color)
    raise PNGFullError if done?
    @png[@ridx_x, @ridx_y] = color
    @ridx_x -= 1
    if @ridx_x < 0
      @ridx_x = @width - 1
      @ridx_y -= 1
    end
    self
  end

  def add_color_at(color, x, y)
    @png[x, y] = color
    self
  end

  def left
    count = 0
    left_idx_x = @idx_x
    left_idx_y = @idx_y
    while(left_idx_y < @height) do
      count += 1
      left_idx_x += 1
      if left_idx_x >= @width
        left_idx_x = 0
        left_idx_y += 1
      end
    end
    count
  end

  def done?
    idx_y == @height
  end
end

