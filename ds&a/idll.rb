# Immutable Doubly Linked List
# ============================
#
# A while back, @MichaelBaker challenged me to make an immutable doubly linked list. I failed.
#
# This idea occurred to me in the shower yesterday, figured I'd try it out.
#
# Seems to work, I feel like it would be reasonably efficient in a language like Haskell.

class IDLL
  class Node
    attr_accessor :data, :succ

    def initialize(data, succ)
      @data, @succ = data, succ
    end

    def f_each(&block)
      block.call(@data)
      @succ.f_each(&block)
    end

    def b_each(&block)
      @succ.b_each(&block)
      block.call(@data)
    end
  end

  Null = Module.new do
    extend self
    def f_each; end
    def b_each; end
    def data; raise IndexError, "You exceeded the list boundaries!" end
  end

  class Cursor
    def initialize(prelist, postlist)
      @prelist = prelist
      @postlist = postlist
    end

    def next_data
      @prelist.data
    end

    def prev_data
      @postlist.data
    end

    def succ
      return self if at_back?
      Cursor.new(@prelist.succ, Node.new(@prelist.data, @postlist))
    end

    def pred
      Cursor.new(Node.new(@postlist.data, @prelist), @postlist.succ)
    end

    def insert_after(data)
      Cursor.new(Node.new(data, @prelist), @postlist)
    end

    def insert_before(data)
      Cursor.new(@prelist, Node.new(data, @postlist))
    end

    def to_list
      return IDLL.new @prelist if at_front?
      pred.to_list
    end

    def at_front?
      @postlist == Null
    end

    def at_back?
      @prelist == Null
    end
  end

  def initialize(front=Null, back=Null)
    @front, @back = front, back
  end

  def prepend(data)
    IDLL.new(Node.new(data, @front), @back)
  end

  def append(data)
    IDLL.new(@front, Node.new(data, @back))
  end

  def f_each(&block)
    return to_enum :f_each unless block
    @front.f_each(&block)
    @back.b_each(&block)
  end

  def b_each(&block)
    return to_enum :b_each unless block
    @back.f_each(&block)
    @front.b_each(&block)
  end

  # traverse the list starting at the front
  def f_cursor
    Cursor.new(
      b_each.inject(Null) { |l, data| Node.new data, l },
      Null
    )
  end

  # traverse the list starting at the back
  def b_cursor
    Cursor.new(
      Null,
      f_each.inject(Null) { |l, data| Node.new data, l }
    )
  end

  def to_a
    f_each.to_a
  end
end
