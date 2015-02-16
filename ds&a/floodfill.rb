# from http://www.reddit.com/r/dailyprogrammer/comments/2ug3hx/20150202_challenge_200_easy_floodfill/
# it's one of our daily challenges

require 'set'

class Floodfill
  # a queue which ignores work it's already done
  class MemoryQueue
    def initialize(initial_work=[])
      @to_process = initial_work.dup
      @seen       = Set.new initial_work
    end
    def enqueue(work)
      return self if @seen.include? work
      @seen       << work
      @to_process << work
      self
    end
    def dequeue
      @to_process.shift
    end
    def empty?
      @to_process.empty?
    end
  end

  class Point
    attr_reader :y, :x
    def initialize(y:, x:)
      @y, @x = y, x
    end
    def neighbours
      return Point.new(y: y,   x: x-1),
             Point.new(y: y,   x: x+1),
             Point.new(y: y-1, x: x),
             Point.new(y: y+1, x: x)
    end
    # Technically passes without these, but does a lot of redundant work
    # because it doesn't recognize the points as being seen since @seen is a set
    def hash
      @hash ||= [y, x].hash
    end
    def eql?(point)
      x == point.x && y == point.y
    end
  end

  class Grid
    attr_reader :width, :height
    def initialize(width:, height:, lines:)
      @lines  = lines
      @height = height
      @width  = width
    end
    def [](point)
      @lines[point.y][point.x]
    end
    def []=(point, value)
      @lines[point.y][point.x] = value
    end
    def wrap_point(point)
      Point.new y: point.y % height, x: point.x % width
    end
    def to_s
      height.times.map { |y|
        width.times.map { |x| self[Point.new y: y, x: x] }.join('') << "\n"
      }.join('')
    end
  end


  def self.parse(input)
    lines     = input.lines.to_a
    w, h      = lines.shift.scan(/\d+/)
    gridlines = h.to_i.times.map { lines.shift }
    x, y, c   = lines.shift.split
    return w.to_i, h.to_i, gridlines, x.to_i, y.to_i, c
  end

  def self.call(raw_input)
    w, h, gridlines, x, y, new_char = parse(raw_input)
    grid        = Grid.new width: w, height: h, lines: gridlines
    start_point = Point.new y: y, x: x
    old_char    = grid[start_point]
    queue       = MemoryQueue.new [start_point]

    until queue.empty?
      crnt_point       = queue.dequeue
      grid[crnt_point] = new_char
      crnt_point.neighbours
                .map    { |point| grid.wrap_point point }
                .select { |point| grid[point] == old_char }
                .each   { |point| queue.enqueue point }
    end

    grid.to_s
  end
end
