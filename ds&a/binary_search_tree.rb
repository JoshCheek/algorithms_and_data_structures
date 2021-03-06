# Another implementation that is more suited to a data structure
# is at https://gist.github.com/JoshCheek/be9616d65989967bda9d
# (this one's pretty custom to just what I need for the sort algo)
class BinarySearchTree
  def self.sort(array, &comparer)
    comparer ||= :<=>.to_proc
    array.inject(Null) { |bst, el| bst.add el, comparer }.to_a
  end

  class << (Null = Module.new)
    def add(el, *)
      BinarySearchTree.new el
    end

    include Enumerable
    def each
      # no op
    end
  end

  def initialize(data)
    @data = data
    @left = @right = Null
  end

  include Enumerable
  def each(&block)
    @left.each &block
    yield @data
    @right.each &block
  end

  def add(data, comparer)
    comparer.call(data, @data) < 0 ?
      @left  = @left.add(data, comparer) :
      @right = @right.add(data, comparer)
    self
  end
end
