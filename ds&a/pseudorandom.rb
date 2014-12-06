# Was watching https://www.youtube.com/v/FfZurPKYM2w?start=350
# "Gambling with Secrets: Part 6/8 (Perfect Secrecy & Pseudorandomness)"
#
# It described a pseudorandom algorithm that John von Neumann came up with
# it seemed interesting and doable, so here we are

class Pseudorandom
  def initialize(seed)
    @seed      = seed
    @seed_size = seed.to_s.size
    @n         = seed
    @seen      = [seed]
    @queue     = num_to_digits(@n)
    @period    = nil
  end

  def inspect
    "#<Pseudorandom seed:#{@seed}>"
  end

  def parts
    enqueue until @period
    index = @seen.size-@period
    # There's probably real words for these things
    { entry:  @seen[0..index],
      cycle:  @seen[index..-1],
      period: @period,
    }
  end

  include Enumerable

  def each
    loop do
      enqueue if @queue.empty?
      yield @queue.shift
    end
  end

  private

  def enqueue
    mid_str = extract_middle (@n*@n).to_s, @seed_size
    @n      = mid_str.to_i
    @period || if index = @seen.index(@n)
      @period = @seen.size - index
    else
      @seen << @n
    end
    @queue.concat num_to_digits(mid_str)
  end

  def extract_middle(str, size)
    return str        if str.size <= size
    return str[1..-1] if str.size == size.next
    extract_middle(str[1...-1], size)
  end

  def num_to_digits(n)
    n.to_s.chars.map(&:to_i)
  end
end

if $0 == __FILE__
  # I'm assuming I did this right, I don't have any real check other than the numbers they
  # flash on screen in the documentary
  r = Pseudorandom.new 121

  # They show a seed of 121 should starting with:
  puts "First 12 sets of 3."
  puts "According to the video, should be 121 464 529 984 ..."
  puts "  \e[35m#{r.take(12).each_slice(3).map(&:join).join(' ')}\e[0m"
  puts

  # Wanders around a bit until it hits 560, which has a period of 4:
  # 464, 529, 984, 825, 62, 844, 233, 428, 318, 112, 254, 451, 340, (560, 360, 960, 160), (560, ...
  puts "I'm getting 4 for period, b/c (560, 360, 960, 160), which is presumably right:"
  puts "\e[35m#{r.parts.map { |k, v| sprintf "  %6s - %p", k, v }.join("\n")}\e[0m"
end
