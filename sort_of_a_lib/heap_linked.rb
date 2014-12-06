# IDK if this is really a heap sort, I'm doing it a little from memory
# and a little just going with what makes sense. Feels like a heapsort,
# but I don't remember ever tracking which branch to push down before.
class HeapLinked
  def self.sort(ary, &comparer)
    ary.each_with_object(new &(comparer || :<=>)) { |element, hs| hs.add element }.pop_all
  end

  Node = Struct.new :data, :left, :right do
    def inspect
      "(#{data.inspect} L#{left.inspect} R#{right.inspect})"
    end
  end

  def initialize(&comparer)
    @comparer = comparer
  end

  def add(data)
    if @head
      push @head, data
    else
      @head = Node.new data
    end
  end

  def pop_all
    sorted = []
    while @head
      @head, data = pop(@head)
      sorted << data
    end
    sorted
  end

  private

  def left_is_less?(left, right)
    @comparer.call(left, right) < 0
  end

  def push(node, data)
    data, node.data = node.data, data if left_is_less?(data, node.data)

    if node.left && node.right
      # for now, push down the path with the largest data
      if left_is_less?(node.left.data, node.right.data)
        push node.right, data
      else
        push node.left, data
      end
    elsif node.left
      node.right = Node.new data
    else
      node.left = Node.new data
    end
  end

  def pop(node)
    to_return = node.data
    if node.left && node.right
      if left_is_less?(node.left.data, node.right.data)
        node.left, node.data = pop(node.left)
      else
        node.right, node.data = pop(node.right)
      end
    elsif node.left
      node.left, node.data = pop(node.left)
    elsif node.right
      node.right, node.data = pop(node.right)
    else
      node = nil
    end
    return node, to_return
  end
end
