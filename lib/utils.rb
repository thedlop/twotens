module Utils
  class AssertionFailureError < StandardError; end

  def self.assert_equals(a, b)
    if (a != b)
      raise AssertionFailureError.new(a: a, b: b)
    end
  end

  def self.assert(a)
    if (!a)
      raise AssertionFailureError.new(a: a)
    end
  end
end
