#require 'rubygems'
#require 'bundler/setup'
$LOAD_PATH << '/usr/local/lib/tens/vendor/bundle/ruby/3.2.0+2/gems/chunky_png-1.4.0/lib'
# puts $LOAD_PATH
require 'chunky_png'
require 'base64'
require 'json'
require_relative './tens_art_v1.rb'

module WasmEntry
  def self.entry
    # puts ARGV.inspect
    parsed = JSON.parse(ARGV[0])
    text = parsed['data']
    keyorder = parsed['keyorder']
    ir_size = parsed['ir_size']
    color_profile = parsed['color_profile'].to_sym
    options = parsed['options'].reduce({}) do |memo, kv|
      k = kv[0]
      v = kv[1]
      if k == 'orientation'
        v = v.to_sym 
      end
      memo.merge({k.to_sym => v})
    end

    encode(text, keyorder, ir_size, color_profile, options)
  end

  # returns [base64'd png string, base64'd scaled png string]
  def self.encode(text, keyorder, ir_size, color_profile, options)
    # TODO: validate_text
    # TODO: validate_keyorder
    # TODO: validate_ir_size
    # TODO: validate_color_profile
    # TODO: validate_options
    nft_data = TensArtV1.new(keyorder, text, options, ir_size: ir_size, color_profile: color_profile)
    nft_data.encode
    bpng = nft_data.to_png
    scaled = bpng.scale_until(200, 200)
    s = ::Base64.encode64(bpng.png.to_blob)
    o = ::Base64.encode64(scaled.png.to_blob)
    puts o
    [o, s]
  end

  def self.decode(png, keyorder)
    decoded = TensArtV1.decode_from_png(png, keyorder: keyorder)
    decoded
  end
end

WasmEntry.entry()

# data = "Dark Lord of Programming"
# keyorder = data.split(//).uniq.join("")
# options = {orientation: :center, padding: 100 }
# ir_size = 6
# color_profile = :gray
#
#{
#  data: data,
#  keyorder: keyorder,
#  options: options,
#  ir_size: ir_size,
#  color_profile: color_profile
#}.to_json
# 
# puts WasmEntry.encode(
#   data,  
#   keyorder,
#   6,
#   :gray,
#   options
# )
# puts "HELLO WASM"