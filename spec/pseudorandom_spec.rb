require 'spec_helper'

require 'pseudorandom'
RSpec.describe Pseudorandom do
  let(:r) { Pseudorandom.new 121 }

  it 'generates digits based on "centers of squares of the seed"' do
    # tested according to the numbers shown in the video
    first_four_numbers = r.take(12).each_slice(3).map { |slice| slice.join.to_i }
    expect(first_four_numbers).to eq [121, 464, 529, 984]
  end

  it 'doesn\'t try to inspect to infinity' do
    expect(r.inspect.length).to be < 100
  end

  it 'knows the entry/cycle/period' do
    expect(r.parts).to eq \
      period: 4,
      entry:  [121, 464, 529, 984, 825, 62, 844, 233, 428, 318, 112, 254, 451, 340, 560],
      cycle:  [560, 360, 960, 160]
  end
end
