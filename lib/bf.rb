class Bf
  class InvalidCommandError < StandardError; end
  attr_accessor :registers, :register_idx, :output, :chars

  def initialize(registers: [], register_idx: 0)
    reset!(registers, register_idx)
  end

  def reset!(set_registers, set_register_idx)
    @_output = true
    @_execution = true
    @output = ""
    @registers = set_registers
    @register_idx = set_register_idx
    @chars = []
  end

  def freeze_execution(&block) 
    @_execute = false
    old_registers = @registers.dup
    lc = yield
    @registers = old_registers
    @_execute = true
    lc
  end

  def freeze_output(&block)
    @_output = false
    lc = yield
    @_output = true
    lc
  end

  def write_loop(loops, &block)
    starting_register_idx = @register_idx
    loops.times { increment_register }
    open_loop
    yield
    until @register_idx == starting_register_idx do
      decrement_register_ptr
    end
    decrement_register
    close_loop
  end

  def execute_loop(loops, &block)
    starting_register_idx = @register_idx
    loops.times { increment_register }
    loops.times do
      yield
      until @register_idx == starting_register_idx do
        decrement_register_ptr
      end
      decrement_register
    end
  end

  def execution_disabled?
    !@_execution
  end

  def output_disabled?
    !@_output
  end

  def new_loop(loops, &block)
    if execution_disabled?
      write_loop(loops, &block)
    elsif output_disabled?
      execute_loop(loops, &block)
    else
      freeze_execution do
        write_loop(loops, &block)
      end
      freeze_output do
        execute_loop(loops, &block)
      end
    end
  end

  def current_register_value
    (@registers[@register_idx] || 0)
  end

  def write(command)
    if output_disabled?
      command
    else
      @output << command
    end
  end

  def open_loop
    write("[")
  end

  def close_loop
    write("]")
  end

  def increment_register
    @registers[@register_idx] = current_register_value + 1
    write("+")
  end

  def decrement_register
    @registers[@register_idx] = current_register_value - 1
    write("-")
  end

  def increment_register_ptr
    @register_idx += 1
    write(">")
  end

  def decrement_register_ptr
    @register_idx -= 1
    if @register_idx < 0
      raise InvalidCommandError.new("Register idx cannot be less than 0")
    end

    write("<")
  end

  def putchar
    @chars << (current_register_value || 0)
    write(".")
  end

  def getchar
    raise NotImplementedError
  end
end
