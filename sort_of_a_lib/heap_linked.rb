require 'loop'

# IDK if this is really a heap sort, I'm doing it a little from memory
# and a little just going with what makes sense. Feels like a heapsort,
# but I don't remember ever tracking which branch to push down before.
class HeapLinked
  def self.sort(ary, &comparer)
    comparer ||= :<=>
    ary.each_with_object(new &comparer) { |el, heap| heap.add el }.pop_all
  end

  Node = Struct.new :data, :left, :right

  def initialize(&comparer)
    @comparer = comparer
  end

  def add(data)
    @head = push @head, data
  end

  def pop_all
    Loop.while { @head }
        .map {
          @head, data = pop @head
          data
        }
  end

  private

  # For now, push down the path with the largest data
  # Seems like if I gave each node a bit to identify which side to push down
  # and then alternated it for each push, that it would cause the tree to be
  # balanced, which should keep it as close to optimal time complexity as possible
  def push(node, data)
    return Node.new data unless node

    data = replace_data(node, data) if is_first?(data, node.data)

    if left_first?(node.left, node.right)
      node.right = push(node.right, data)
    else
      node.left  = push(node.left, data)
    end

    node
  end

  def pop(node)
    to_return = node.data

    if left_first?(node.left, node.right)
      node.left, node.data = pop(node.left)
    elsif node.right
      node.right, node.data = pop(node.right)
    else
      node = nil
    end

    return node, to_return
  end

  def is_first?(left_data, right_data)
    @comparer.call(left_data, right_data) < 0
  end

  # IDK if this is more communicative or less
  # I like it better than tap
  # and it takes no variable tracking, unlike either of the normal swaps (a, b.c = b.c, a) and (temp = b.c; b.c = a; temp)
  # but it's atypical, and so could cause people to go "huh?"
  def replace_data(node, data)
    node.data
  ensure
    node.data = data
  end

  def left_first?(left_node, right_node)
    return false unless left_node             # not first if it DNE
    return true  unless right_node            # is first if it's the only node
    is_first? left_node.data, right_node.data # compare to find out
  end
end
