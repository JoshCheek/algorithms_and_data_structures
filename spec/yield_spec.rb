require 'spec_helper'
require 'loop'

RSpec.describe Loop do
  describe '.while' do
    it 'returns an enumerator that yields while the block returns true' do
      # is enum
      ary = %w(a b c)
      w   = Loop.while { ary.any? }
      expect(w).to be_a_kind_of Enumerator

      # behaves like an enum
      c = w.reduce("") { |concatenated| concatenated + ary.shift }
      expect(c).to eq "abc"

      # doesn't iterate when condition is false
      Loop.while { false }.do { raise "this shouldn't be called" }
    end

    it 'yields nil by default' do
      i = -1
      ary = Loop.while { (i+=1) < 3 }.to_a
      expect(ary).to eq [nil, nil, nil]
    end

    specify '`yield` yields the specified value' do
      i = -1
      ary = Loop.while { (i+=1) < 3 }.yield { i * 10 }.to_a
      expect(ary).to eq [0, 10, 20]
    end

    it 'iterates immediately when given a `do`' do
      source = [1,2,3]
      dest   = []
      Loop.while { source.any? }.do { dest.push source.pop }
      expect(dest).to eq [3,2,1]
    end
  end
end
