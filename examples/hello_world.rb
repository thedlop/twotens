require_relative '../lib/bf.rb'

# Hello World example using Bf DSL
def hello_world
  bf = Bf.new
  
  # build up registers with
  # 0 0 32 80 104 120
  # Loop over register 0, building up registers with reference values
  # r0
  bf.new_loop(8) do
    #r1
    bf.increment_register_ptr
    bf.new_loop(5) do
      # r3, 80
      2.times { bf.increment_register_ptr }
      2.times { bf.increment_register }

      # r4, 104
      bf.increment_register_ptr
      2.times { bf.increment_register }

      # r5, 120
      bf.increment_register_ptr
      3.times { bf.increment_register }
    end
    # r2, 32
    bf.increment_register_ptr
    4.times { bf.increment_register }

    # r4, 104
    2.times { bf.increment_register_ptr }
    3.times { bf.increment_register }
  end

  original_register_ptr = bf.register_idx
  codepoints = "hello world".codepoints

  # build hello world string with closest registers
  codepoints.each do |cp|
    closest_register_idx = nil
    bf.registers.each_with_index do |v, idx|
      if closest_register_idx.nil? || 
          (v - cp).abs < (bf.registers[closest_register_idx] - cp).abs 

        closest_register_idx = idx
      end
    end

    until bf.register_idx == closest_register_idx
      if bf.register_idx < closest_register_idx
        bf.increment_register_ptr
      else
        bf.decrement_register_ptr
      end
    end

    original_register_value = bf.current_register_value
    until bf.current_register_value == cp
      if bf.current_register_value > cp
        bf.decrement_register
      else
        bf.increment_register
      end
    end

    bf.putchar
  end

  bf
end

# Generate the Bf program
bfp = hello_world
# To see produced Brainfuck source
puts bfp.output
# To see "putted" characters; what is printed when program is executed 
puts bfp.chars
# Convert byte to ascii and transfrom array to string to see the actual text
puts bfp.chars.map(&:chr).join

