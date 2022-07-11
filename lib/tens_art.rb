require_relative './tens_static_section.rb'
require_relative './utils.rb'
require_relative './tens_section_dependent.rb'
require_relative './tens_section_with_data.rb'
require_relative './tens_section_dependent/tens_section_internal_dependent.rb'
require_relative './unique_two_way_hash.rb'
require_relative './color_profile/mapped_color_profile.rb'
require_relative './color_profile/gray_color_profile.rb'
require_relative './color_profile/gray_inverted_color_profile.rb'
require_relative './color_profile/red_color_profile.rb'
require_relative './color_profile/blue_color_profile.rb'
require_relative './color_profile/green_color_profile.rb'
require_relative './color_profile/rgb_color_profile.rb'
require_relative './color_profile/bgr_color_profile.rb'
require_relative './color_profile/brg_color_profile.rb'
require_relative './color_profile/gbr_color_profile.rb'
require_relative './color_profile/grb_color_profile.rb'
require_relative './color_profile/rbg_color_profile.rb'

class TensArt
  class VersionNotImplementedError < StandardError; end
  class InvalidVersionError < StandardError; end
  class InvalidDataTypeError < StandardError; end

  # ORDER MATTERS, ONLY APPEND
  COLOR_PROFILES =
    [
      :gray,
      :red,
      :green,
      :blue,
      :rgb,
      :gray_inverted,
      :brown,
      :purple,
      :bgr,
      :brg,
      :grb,
      :gbr,
      :rbg,
      :yellow,
      :aqua,
    ].freeze

  # Color Profile Section
  COLOR_PROFILE_COLORS = begin
    h = Hash.new { |h, k| raise InvalidColorProfileError.new(key: k, allowed: "#{COLOR_PROFILES.inspect}") }
    # IF more than 255 CPs are added we will have to figure something else out
    Utils.assert(COLOR_PROFILES.length < 255)
    idx = 0
    c = COLOR_PROFILES.reduce({}) do |memo, cp|
      idx += 1
      memo.merge({ cp => [idx, idx, idx]})
    end
    h.merge!(c)
  end.freeze

  def self.color_profile_section
    TensStaticSection.new(:color_profile, COLOR_PROFILE_COLORS.dup)
  end

  def color_profile_section
    @_cpss ||= self.class.color_profile_section
  end

  def self.assert_valid_color_profile(new_color_profile)
    if COLOR_PROFILES.include?(new_color_profile)
      return new_color_profile
    end

    raise InvalidDataTypeError.new(given: new_color_profile, expected: "One of #{COLOR_PROFILES.inspect}", message: "Color profile is invalid")
  end

  def self.color_profile_to_png(color_profile, eightbit_tokens)
    case color_profile
    when :gray
      GrayColorProfile.new.to_png(eightbit_tokens) 
    when :gray_inverted
      GrayInvertedColorProfile.new.to_png(eightbit_tokens) 
    when :red
      RedColorProfile.new.to_png(eightbit_tokens) 
    when :green
      GreenColorProfile.new.to_png(eightbit_tokens) 
    when :blue
      BlueColorProfile.new.to_png(eightbit_tokens) 
    when :rgb
      RgbColorProfile.new.to_png(eightbit_tokens) 
    when :brown
      BrownColorProfile.new.to_png(eightbit_tokens) 
    when :purple
      PurpleColorProfile.new.to_png(eightbit_tokens) 
    when :bgr
      BgrColorProfile.new.to_png(eightbit_tokens) 
    when :brg
      BrgColorProfile.new.to_png(eightbit_tokens) 
    when :gbr
      GbrColorProfile.new.to_png(eightbit_tokens) 
    when :grb
      GrbColorProfile.new.to_png(eightbit_tokens) 
    when :rbg
      RbgColorProfile.new.to_png(eightbit_tokens) 
    when :yellow
      YellowColorProfile.new.to_png(eightbit_tokens) 
    when :aqua
      AquaColorProfile.new.to_png(eightbit_tokens) 
    else
      raise NotImplementedError
    end
  end

  def self.color_profile_from_png(color_profile, png_triples)
    case color_profile
    when :gray
      GrayColorProfile.new.from_png(png_triples)
    when :gray_inverted
      GrayInvertedColorProfile.new.from_png(png_triples)
    when :red
      RedColorProfile.new.from_png(png_triples) 
    when :green
      GreenColorProfile.new.from_png(png_triples) 
    when :blue
      BlueColorProfile.new.from_png(png_triples) 
    when :rgb
      RgbColorProfile.new.from_png(png_triples) 
    when :brown
      BrownColorProfile.new.from_png(png_triples) 
    when :purple
      PurpleColorProfile.new.from_png(png_triples) 
    when :bgr
      BgrColorProfile.new.from_png(png_triples) 
    when :brg
      BrgColorProfile.new.from_png(png_triples) 
    when :grb
      GrbColorProfile.new.from_png(png_triples) 
    when :gbr
      GbrColorProfile.new.from_png(png_triples) 
    when :rbg
      RbgColorProfile.new.from_png(png_triples) 
    when :yellow
      YellowColorProfile.new.from_png(png_triples) 
    when :aqua
      AquaColorProfile.new.from_png(png_triples) 
    else
      raise NotImplementedError
    end
  end

  # DO NOT MODIFY, ONLY APPEND
  IR_SIZES = 
    [
      4,
      5,
      6,
      7,
      8,
      3,
      9,
    ].freeze

  def self.assert_valid_ir_size(new_ir_size)
    if IR_SIZES.include?(new_ir_size)
      return new_ir_size
    end

    raise InvalidDataTypeError.new(given: new_ir_size, expected: "One of #{IR_SIZES.inspect}", message: "Ir size is invalid")
  end

  IR_SIZE_COLORS = begin
    h = Hash.new { |h, k| raise InvalidIRSizeError.new(key: k, allowed: "#{IR_SIZES.inspect}") }

    idx = -1
    c = IR_SIZES.reduce({}) do |memo, cp|
      idx += 1
      memo.merge({ cp => [idx, idx, idx]})
    end
    h.merge!(c)
    h
  end.freeze

  def self.ir_size_section
    TensStaticSection.new(:ir_size, IR_SIZE_COLORS.dup)
  end

  def ir_size_section
    @_irss ||= self.class.ir_size_section
  end

  # Subclass needs to set version, must be an integer
  def self.version
    raise VersionNotImplementedError
  end

  def self.version_color
    _version = self.version
    # If we ever have more than 256 versions, we'll need to handle
    # those a bit differently
    if !_version.is_a?(Integer) || _version < 0 || _version > 255
      raise InvalidVersionError.new(version: _version)
    end
    [_version, _version, _version]
  end

  def self.version_section
    token_colors = { version => version_color }
    TensStaticSection.new(:version, token_colors)
  end

  def version_section
    @_vs ||= self.class.version_section
  end

  # ir_size + color_profile + ir => png
  # Array(Int) => Array(Array(Int)[3])
  def convert_ir_to_png_triples(encoded, ir_size, color_profile)
    eightbit_tokens,_ = self.class.nbit_to_mbit(ir_size, 8, encoded)

    self.class.color_profile_to_png(color_profile, eightbit_tokens)
  end

  def self.png_triples_to_ir(png_triples, ir_size, color_profile, ir_length)
    assert_valid_ir_size(ir_size)
    eightbit_tokens = self.color_profile_from_png(color_profile, png_triples)
    ir_tokens,_ = nbit_to_mbit(8, ir_size, eightbit_tokens, target_length: ir_length)
    ir_tokens
  end

  # params: original_bit_size(int), target_bit_size(int), numbers(Array(int))
  # returns: [Array(Int), Int]
  # Turns n-bit integers into m-bit integers
  def self.nbit_to_mbit(original_bit_size, target_bit_size, numbers, target_length: nil)
    return [[], 0] if numbers.empty?
    if numbers.any? { |n| n < 0 }
      raise ArgumentError.new("numbers must be greater than or equal to 0") 
    end
    if n = numbers.find { |n| n.bit_length > original_bit_size  }
      raise ArgumentError.new("numbers cannot be greater than the passed in bit_size: #{n} #{n.bit_length}, original_bit_size: #{original_bit_size}") 
    end
    if original_bit_size <= 0 || target_bit_size <= 0
      raise ArgumentError.new("original_bit_size and target_bit_size must be > 0") 
    end

    original_length = numbers.length
    return [numbers, original_length] if original_bit_size == target_bit_size

    local_numbers = numbers.dup
    mbit_numbers = []
    current = 0
    current_bits_read = 0

    number = nil
    number_bits_read = original_bit_size

    loop do
      if(current_bits_read == target_bit_size)
        break if target_length && mbit_numbers.length == target_length
        mbit_numbers.push(current)
        current = 0
        current_bits_read = 0
      end

      if(number_bits_read == original_bit_size)
        break if local_numbers.empty?
        number = local_numbers.shift
        number_bits_read = 0
      end
      mask = number[number_bits_read] << current_bits_read
      current |= mask
      number_bits_read += 1
      current_bits_read += 1
    end
  
    if !target_length && current_bits_read > 0
      mbit_numbers.push(current)
    end

    [mbit_numbers, original_length]
  end

end
