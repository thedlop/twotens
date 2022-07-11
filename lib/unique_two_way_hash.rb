class UniqueTwoWayHash
  class KeyAlreadyExistsError < StandardError; end
  class ValueAlreadyExistsError < StandardError; end
  class NotFoundError < StandardError; end

  def initialize(init_hash = {})
    @forward = {}
    @backward = {}
    merge!(init_hash) unless init_hash.empty?
  end

  def forward
    @forward.dup
  end

  def backward
    @backward.dup
  end

  def get(key)
    @forward[key]
  end

  def get!(key)
    r = @forward[key]
    raise NotFoundError.new(key: key) if r.nil?
    r
  end

  def backward_get(key)
    @backward[key]
  end

  def backward_get!(key)
    r = @backward[key]
    raise NotFoundError.new(key: key) if r.nil?
    r
  end

  # hash
  def merge!(hash)
    hash.each do |(k, v)|
      raise KeyAlreadyExistsError.new(key: k) unless @forward[k].nil?
      raise ValueAlreadyExistsError.new(value: v) unless @backward[v].nil?
      @forward[k] = v
      @backward[v] = k
    end
  end

  def backward_merge!(hash)
    inverted_hash = hash.invert
    merge!(hash)
  end

  def hash
    @forward.hash
  end
end
