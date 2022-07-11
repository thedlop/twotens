require 'rubygems'
require 'bundler/setup'
require 'chunky_png'
require_relative './tens_art.rb'
require_relative './utils.rb'
require_relative './building_png.rb'

class TensArtV1 < TensArt
  class InvalidIRSizeError < StandardError; end
  class InvalidColorProfileError < StandardError; end
  class InvalidBlankError < StandardError; end
  attr_accessor :key_order_section, :options_orientation_section, :options_padding_section,
    :file_section, :signature_section, :options, :key_order, :data

  attr_reader :metadata_keyorder

  attr_reader :ir_size, :color_profile, :ir_tokens

  def self.version
    1
  end

  SECTION_ORDER =
    [ 
      :version,
      :ir_size,
      :color_profile,
      :blank_bit,
      :blank_bit,
      :blank_bit,
      :key_order,
      :options_orientation,
      :options_padding,
      :file,
      :signature
    ].freeze

  def init_sections(ir_tokens)
    self.key_order_section = TensSectionWithData.new("key_order", @key_order, internal_tokens: all_internal_tokens, ir_tokens: ir_tokens)
    self.options_orientation_section = TensSectionInternalDependent.new("options_orientation")
    self.options_padding_section = TensSectionInternalDependent.new("options_padding")
    self.file_section = TensSectionDependent.new("file")
    self.signature_section = TensSectionInternalDependent.new("signature")
  end

  def initialize(key_order, data, options, ir_size: 8, color_profile: :gray, metadata_keyorder: false, ir_tokens: nil)
    @key_order = key_order
    @data = data
    @ir_size = self.class.assert_valid_ir_size(ir_size)
    @color_profile = self.class.assert_valid_color_profile(color_profile)
    @metadata_keyorder = metadata_keyorder
    @options = default_options.merge((options || {}))

    if @data.is_a?(String)
      @data = @data.split(//)
    end
    if @key_order.is_a?(String)
      @key_order = @key_order.split(//)
    end

    init_sections(ir_tokens)
  end

  BLANK_MAP = begin
    h = Hash.new { |h, k| raise InvalidBlankError.new(key: k, allowed: ":blank") }
    h.merge!({
      :blank => [0,0,0],
    })
  end.freeze

  def self.blank_bit_section
    TensStaticSection.new(:blank_bit, BLANK_MAP.dup)
  end

  def blank_bit_section
    @_bbss ||= self.class.blank_bit_section
  end

  def self.default_options
    {
      orientation: :left,
      padding: 0,
    }
  end

  def default_options
    self.class.default_options
  end

  # Unique configuration for this instance
  def release_config
    options.merge({
      "Internal Representation Size": "#{ir_size} bits",
      "Color Profile": color_profile
    })
  end

  def valid_options_integers
    @_voi ||= [0,1,2,3,4,5,6,7,8,9].map{ |d| :"options_#{d}" }
  end 

  def options_integer_in(integer)
    raise InvalidDataTypeError.new(data: integer, expected: 'Integer') unless integer.is_a?(Integer)

    integer.digits.reverse.map do |digit|
      :"options_#{digit}"
    end
  end

  def options_integer_out(options_integer)
    unless options_integer.is_a?(Array)
      raise InvalidDataTypeError.new(data: options_integer, expected: valid_options_integers)
    end

    unless options_integer.all?{ |oi| valid_options_integers.include?(oi) }
      raise InvalidDataTypeError.new(data: options_integer, expected: valid_options_integers)
    end

    options_integer.map do |oi|
      oi.to_s.split("_")[-1]
    end.join.to_i
  end

  # Options hash value -> Tokenized
  # padding: ?Integer
  def options_padding_in(padding)
    default_padding = :options_off
    parsed = nil

    if padding
      parsed = options_integer_in(padding)
    end

    # set to default if nothing was parsed
    parsed ||= [default_padding]
  end

  # Tokenized -> Options hash value
  def options_padding_out(tokenized_padding)
    return nil if tokenized_padding == [:options_off]

    options_integer_out(tokenized_padding)
  end

  def valid_orientation_in_values
    [:left, :center, :right]
  end

  def valid_orientation_out_values
    [:options_orientation_left, :options_orientation_center, :options_orientation_right]
  end

  # Orientation is required
  def options_orientation_in(orientation)
    unless valid_orientation_in_values.include?(orientation)
      raise InvalidDataTypeError.new(data: orientation, expected: valid_orientation_in_values)
    end

    :"options_orientation_#{orientation}"
  end

  def options_orientation_out(tokenized_orientation)
    unless valid_orientation_out_values.include?(tokenized_orientation)
      raise InvalidDataTypeError.new(data: tokenized_orientation, expected: valid_orientation_out_values)
    end

    tokenized_orientation.to_s.split("_")[-1].to_sym
  end

  def self.all_internal_tokens
    [
      :options_off,
      #### orientation
      :options_orientation_left,
      :options_orientation_center,
      :options_orientation_right,
      #### spacing
      :options_spacing,
      #### padding
      :options_0,
      :options_1,
      :options_2,
      :options_3,
      :options_4,
      :options_5,
      :options_6,
      :options_7,
      :options_8,
      :options_9,
      #### general internal
      TensSectionDependent::INTERNAL_START_TOKEN,
      TensSectionDependent::INTERNAL_END_TOKEN,
      #### signature
      :d, :l, :o, :p
    ]
  end

  def all_internal_tokens
    @_oit ||= self.class.all_internal_tokens
  end

  def default_color_key
    :options_spacing
  end

  def prepare_options
    # Orientation
    orientation = options_orientation_in(@options[:orientation])
    self.options_orientation_section.data = [orientation]

    # Padding
    padding = options_padding_in(@options[:padding])
    self.options_padding_section.data = padding
  end

  def prepare_signature
    self.signature_section.data =  [:d, :l, :o, :p]
  end

  def prepare_file
    self.file_section.data = @data
  end

  def prepare_sections
    # key_order was already prepared in init_sections
    prepare_options
    prepare_signature
    prepare_file
  end

  def encode
    @_encoding = nil
    @_side_length = nil

    prepare_sections

    # complexity is number of unique characters in encoding
    complexity = @key_order_section.tokens.count

    # encode version section
    version_encoded = version_section.encode([self.class.version])

    # encode ir_size section
    ir_size_encoded = ir_size_section.encode([ir_size])

    # encode color_profile section
    color_profile_encoded = color_profile_section.encode([color_profile])

    # encode blank_bit section
    bb_encoded = blank_bit_section.encode([:blank])

    # encode key_order section
    key_order_encoded = @key_order_section.encode

    # encode options
    options_orientation_encoded = @options_orientation_section.encode(@key_order_section.data_ir_map)
    options_padding_encoded = @options_padding_section.encode(@key_order_section.data_ir_map)
    options_encoded = options_orientation_encoded + options_padding_encoded

    # encode file section
    file_encoded = @file_section.encode(@key_order_section.data_ir_map)

    # encode signature section
    sig_encoded = @signature_section.encode(@key_order_section.data_ir_map)

    header_length = version_encoded.length +
      ir_size_encoded.length +
      color_profile_encoded.length +
      # Three blank bit sections
      bb_encoded.length +
      bb_encoded.length +
      bb_encoded.length

    ir_length = key_order_encoded.length +
      options_encoded.length +
      file_encoded.length +
      sig_encoded.length

    padding = padding_length(file_encoded.length)

    ir_length += padding

    default_color = @key_order_section.data_ir_map.get!(default_color_key)
    header = []

    # version
    header += version_encoded
    # ir size
    header += ir_size_encoded
    # color_profile
    header += color_profile_encoded
    # blank bits
    header += bb_encoded
    header += bb_encoded
    header += bb_encoded

    encoding = Array.new(ir_length, default_color)
    idx = 0
    # key_order
    key_order_encoded.each do |key_order_single|
      encoding[idx] = key_order_single
      idx += 1
    end

    # options
    options_encoded.each do |options_single|
      encoding[idx] = options_single
      idx += 1
    end

    # file
    encoding, idx = apply_file_encoding(encoding, idx, file_encoded, sig_encoded.length)

    encoding, idx = apply_sig_encoding(encoding, idx, sig_encoded)

    # Assert we made it to the end
    Utils.assert_equals(idx, encoding.length) 

    @_encoding = encoding
    @_header = header
  end

  def apply_sig_encoding(encoding, original_idx, sig_encoded)
    slots_left = encoding.length - original_idx
    starting_idx = original_idx + slots_left - sig_encoded.length

    idx = starting_idx
    # signature 
    sig_encoded.each do |sig_single|
      encoding[idx] = sig_single
      idx += 1
    end

    [encoding, idx]
  end

  def apply_file_encoding(encoding, original_idx, file_encoded, sig_encoded_length)
    # Subtract signature
    slots_left = encoding.length - original_idx - sig_encoded_length
    file_encoded_length = file_encoded.length 

    # determine where to start file encoding based
    # on orientation
    case @options[:orientation]
    when :left
      starting_idx = original_idx
    when :right
      starting_idx = encoding.length - sig_encoded_length - file_encoded_length
    when :center
      starting_idx = original_idx + (slots_left - file_encoded_length) / 2
    end

    idx = starting_idx
    file_encoded.each do |file_single|
      encoding[idx] = file_single
      idx += 1
    end

    [encoding, idx]
  end

  def to_png
    Utils.assert(@_encoding.is_a?(Array))
    Utils.assert(@_header.is_a?(Array))
    ir_triples = convert_ir_to_png_triples(@_encoding, @ir_size, @color_profile)
    
    all_triples = @_header + ir_triples
    triples_length = @_header.length + ir_triples.length

    # compute minimum png side length
    side_length = 0
    until(side_length * side_length > triples_length) do
      side_length += 1
    end
    actual_length = side_length * side_length

    png_filler_color = [0,0,0]
    png_filler = Array.new(actual_length - triples_length, png_filler_color)
    final_encoding = @_header + ir_triples + png_filler

    png = BuildingPNG.new(side_length, side_length)
    idx = 0
    color = nil
    until idx == actual_length
      color = ChunkyPNG::Color.rgb(*final_encoding[idx])
      png.add_next_color(color)
      idx += 1
    end

    # apply metadata to png
    if @metadata_keyorder
      png.png.metadata['k'] = @key_order.join("")
    end
    # ir tokens count, required for decoding
    png.png.metadata['i'] = @_encoding.length.to_s
    # png filler length, so we can use arbitrary filler colors, decoder
    # will slice these out before translating to ir 
    png.png.metadata['f'] = png_filler.length.to_s

    # ensure we filled up the png
    Utils.assert(png.done?)

    @_png = png
  end

  # Translates png -> [Int[3], ...] which is the @_encoding format
  def self.decode_from_png(png_file, keyorder: nil)
    png_triples = []
    png = ChunkyPNG::Image.from_file(png_file)
    width = png.width
    height = png.height
    w_idx = 0
    h_idx = 0
    until h_idx >= height
      color = ChunkyPNG::Color.to_truecolor_bytes(png[w_idx,h_idx])
      png_triples.push(color)
      w_idx += 1
      if w_idx >= width
        w_idx = 0
        h_idx += 1
      end
    end
    _keyorder = nil
    _ir_size = nil
    # If keyorder set on png, use that
    _keyorder = png.metadata['k']
    _keyorder ||= keyorder
    raise NoKeyorderError.new if _keyorder.nil?
    ir_length = png.metadata['i'].to_i
    raise InvalidIRSizeError.new if ir_length <= 0
    filler_length = png.metadata['f'].to_i

    # remove filler before passing on to decoder
    png_triples.slice!(png_triples.length-filler_length..-1)

    decode(png_triples, _keyorder, ir_length)
  end

  def padding_length(file_encoded_length)
    # return 0 if padding set to 0
    return 0 if @options[:padding] == 0

    # Coerce to int, drop off decimals (round down)
    # ex: 1.5 -> 1
    # ex: 1.2 -> 1
    # ex: 0.3 -> 0
    (file_encoded_length * (@options[:padding] / 100.0)).to_i
  end

  # Ignore tokens while decoding
  def self.ignore_tokens_while_decoding
    @_ignore_tokens ||= [:options_spacing]
  end

  def self.decode(png_triples, key_order, ir_length)
    current_section_idx = 0
    # parse and check version
    decoded_version = version_section.decode([png_triples.shift]).first
    current_section_idx += 1
    Utils.assert_equals(decoded_version, self.version)

    # Parse Static Sections
    # parse ir_size
    decoded_ir_size = ir_size_section.decode([png_triples.shift]).first
    current_section_idx += 1

    # parse color_profile
    decoded_color_profile = color_profile_section.decode([png_triples.shift]).first
    current_section_idx += 1

    # parse blank_bit_one
    blank_1 = blank_bit_section.decode([png_triples.shift])
    current_section_idx += 1

    # parse blank_bit_two
    blank_2 = blank_bit_section.decode([png_triples.shift])
    current_section_idx += 1

    # parse blank_bit_three
    blank_3 = blank_bit_section.decode([png_triples.shift])
    current_section_idx += 1

    # Parse Dynamic Sections (based on keyorder)
    # convert png triple to 8-bit from color_profile and
    # convert 8-bit to ir_size
    ir_tokens = png_triples_to_ir(png_triples, decoded_ir_size, decoded_color_profile, ir_length)

    # slice out keyorder tokens to build up data<->ir map
    full_keyorder_length = key_order.length + all_internal_tokens.length
    ir_tokens_for_keyorder = ir_tokens.slice!(0, full_keyorder_length)
    ta = TensArtV1.new(key_order, [], {}, ir_size: decoded_ir_size, color_profile: decoded_color_profile, ir_tokens: ir_tokens_for_keyorder)

    current_section_idx += 1
    current_section = SECTION_ORDER[current_section_idx]

    # translate all ir to data
    tokens = ir_tokens.map do |e|
      ta.key_order_section.data_ir_map.backward_get!(e)
    end
    
    while(tokens.length > 0 && current_section_idx < SECTION_ORDER.length) do
      if ignore_tokens_while_decoding.include?(tokens[0])
        tokens.shift
        next 
      end

      case current_section
        when :key_order
          tokens = ta.decode_key_order(tokens)
        when :options_orientation
          tokens = ta.decode_options_orientation(tokens)
        when :options_padding
          tokens = ta.decode_options_padding(tokens)
        when :file
          tokens = ta.decode_file(tokens)
        when :signature
          tokens = ta.decode_signature(tokens)
      end
      current_section_idx += 1 
      current_section = SECTION_ORDER[current_section_idx]
    end

    ta
  end

  def decode_key_order(encoded)
    # we already have key_order since it is derived from input params
    # and static internal data
    encoded.shift(key_order_section.tokens.length)
    encoded
  end

  def decode_options_orientation(tokens)
    # decode orientation
    self.options_orientation_section.decode_with_tokens!(tokens)

    # set internal options
    orientation = options_orientation_out(self.options_orientation_section.data.first)
    self.options.merge!(orientation: orientation)

    tokens
  end

  def decode_options_padding(tokens)
    # decode padding
    self.options_padding_section.decode_with_tokens!(tokens)

    # set internal options
    padding = options_padding_out(self.options_padding_section.data)
    self.options.merge!(padding: padding)

    tokens
  end

  def decode_file(tokens)
    self.file_section.decode_with_tokens!(tokens)
    self.data = self.file_section.data
    tokens
  end

  def decode_signature(tokens)
    self.signature_section.decode_with_tokens!(tokens)
    tokens
  end
end
