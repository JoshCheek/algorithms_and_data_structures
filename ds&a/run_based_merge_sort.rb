# First pass at a sort algorithm in my brain (needs refactoring, obviously)

# Sorts a queue in a merge-sort style,
# but instead of splitting it into halves
# it splits on boundaries of unsortedness
# (e.g. increasing numbers become decreasing or vice versa)
class RunBasedMergeSort
  def self.sort(ary)
    chunks = chunk_up(ary)
    until chunks.size == 1
      l, r = chunks.shift 2
      chunks.push merge(l, r)
    end
    q = Q.new(chunks.first)
    sorted = []
    sorted << q.dequeue while q.any?
    sorted
  end

  def self.chunk_up(ary)
    return [ary] if ary.size < 3
    prev      = ary[0]
    direction = :pending
    ary.slice_before { |c|
      if :pending == direction
        if prev < c
          direction = :up
        elsif prev > c
          direction = :down
        else
          direction = :pending
        end
        prev = c
        false
      elsif :up == direction && prev <= c
        prev      = c
        false # up/up - don't chunk
      elsif :up == direction
        prev      = c
        direction = :pending
        true # up/down - chunk
      elsif prev >= c
        prev      = c
        false # down/down - don't chunk
      else
        prev      = c
        direction = :pending
        true # down/up - chunk
      end
    }.to_a
  end

  def self.merge(ary1, ary2)
    sorted = []
    l = Q.new(ary1)
    r = Q.new(ary2)
    while l.any? && r.any?
      if l.peek < r.peek
        sorted << l.dequeue
      else
        sorted << r.dequeue
      end
    end
    sorted << l.dequeue while l.any?
    sorted << r.dequeue while r.any?
    sorted
  end

  class Q
    def initialize(ary)
      @ary       = ary
      @direction = ary.empty?           ? :up :
                   ary.first < ary.last ? :up :
                                          :down
    end

    def any?
      @ary.any?
    end

    def peek
      if @direction == :up
        @ary.first
      else
        @ary.last
      end
    end

    def dequeue
      if @direction == :up
        @ary.shift
      else
        @ary.pop
      end
    end
  end
end
