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

  # for now, push down the path with the largest data
  def push(node, data)
    return Node.new data unless node

    data = swap_current(node, data) if left_first?(data, node.data)

    push_right = ( node.left  &&
                   node.right &&
                   left_first?(node.left.data, node.right.data)
                 ) || (
                   node.left && !node.right
                 )

    if push_right
      node.right = push(node.right, data)
    else
      node.left  = push(node.left, data)
    end

    node
  end

  def pop(node)
    to_return = node.data

    pop_left = ( node.left  &&
                 node.right &&
                 left_first?(node.left.data, node.right.data)
               ) || (
                 node.left && !node.right
               )

    if pop_left
      node.left, node.data = pop(node.left)
    elsif node.right
      node.right, node.data = pop(node.right)
    else
      node = nil
    end
    return node, to_return
  end

  def left_first?(left_data, right_data)
    @comparer.call(left_data, right_data) < 0
  end

  def swap_current(node, data)
    to_return = node.data
    node.data = data
    to_return
  end
end
