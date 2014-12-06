require 'spec_helper'
require 'loop'

RSpec.describe Loop do
  it 'yields while the block returns true' do
    # is enum
    ary = %w(a b c)
    w   = Loop.new { ary.any? }
    expect(w).to be_a_kind_of Enumerator

    # behaves like an enum
    c = w.reduce("") { |concatenated| concatenated + ary.shift }
    expect(c).to eq "abc"

    # doesn't iterate when condition is false
    Loop.new { false }.do { raise "this shouldn't be called" }
  end

  it 'yields nil by default' do
    i = -1
    ary = Loop.new { (i+=1) < 3 }.to_a
    expect(ary).to eq [nil, nil, nil]
  end

  specify '`yield` yields the specified value' do
    i = -1
    ary = Loop.new { (i+=1) < 3 }.yield { i * 10 }.to_a
    expect(ary).to eq [0, 10, 20]
  end

  it 'iterates immediately when given a `do`' do
    source = [1,2,3]
    dest   = []
    Loop.new { source.any? }.do { dest.push source.pop }
    expect(dest).to eq [3,2,1]
  end

  describe '.while' do
    it 'is the same as Loop.new' do
      ary = %w(a b c)
      str = Loop.new { ary.any? }.reduce("") { |concatenated| concatenated + ary.shift }
      expect(str).to eq "abc"
    end
  end
end
