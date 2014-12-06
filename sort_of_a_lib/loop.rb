class Loop < Enumerator
  def self.while(&condition)
    Loop.new(&condition)
  end

  alias do each

  def initialize(&condition)
    @condition = condition
    @yielder   = lambda { }
    super { |y| y.yield @yielder.call while @condition.call }
  end

  def yield(&yielder)
    @yielder = yielder
    self
  end
end
