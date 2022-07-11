require 'rubygems'
require 'bundler/setup'
require 'chunky_png'
require_relative '../lib/tens_art_v1.rb'

# This is the slightly modified release code for the DLP set
# https://twotens.art/sets/dlp.html

data = "Dark Lord of Programming"
keyorder = data.split(//).uniq.join("")

def dlp_release(keyorder, data, ir_size, color_profile)
  options = {orientation: :center, padding: 100 }

  nft_data = TensArtV1.new(keyorder, data, options, ir_size: ir_size, color_profile: color_profile)
  nft_data.encode
  original = nft_data.to_png                                             
  scaled = original.scale_until(200,200)                                 
  [original, scaled]
end

nfts = [
  dlp_release(keyorder, data, 6,:gray),
  dlp_release(keyorder, data, 7,:gray),
  dlp_release(keyorder, data, 8,:gray),
  dlp_release(keyorder, data, 6,:red),
  dlp_release(keyorder, data, 7,:red),
  dlp_release(keyorder, data, 8,:red),
  dlp_release(keyorder, data, 6,:green),
  dlp_release(keyorder, data, 7,:green),
  dlp_release(keyorder, data, 8,:green),
  dlp_release(keyorder, data, 6,:blue),
  dlp_release(keyorder, data, 7,:blue),
  dlp_release(keyorder, data, 8,:blue),
  dlp_release(keyorder, data, 6,:rgb),
  dlp_release(keyorder, data, 7,:rgb),
  dlp_release(keyorder, data, 8,:rgb),
]

# To save pngs to filesystem
# nfts[0][0].save("dlp_1_original.png")
# nfts[0][1].save("dlp_1_scaled.png")

# To decode png to a TensArtV1 object ... only works with originals
# decoded = TensArtV1.decode_from_png("dlp_1_original.png", keyorder: keyorder)

# To view the original encoded data after a decode
# puts decoded.data.inspect
