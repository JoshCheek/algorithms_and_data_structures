require 'spec_helper'

def self.assert_sorts(klass, pending:[], tag:, in_place:)
  pending = Array pending

  RSpec.describe klass, tag => true do
    define_method(:sort) { |ary, &comparer| klass.sort ary, &comparer }

    it 'sorts an empty list' do
      expect(sort []).to eq []
    end

    it 'sorts a list with 1 element' do
      expect(sort [1]).to eq [1]
    end

    it 'sorts a list with 2 elements' do
      expect(sort [1, 2]).to eq [1, 2]
      expect(sort [2, 1]).to eq [1, 2]
    end

    it 'sorts a list with 3 elements' do
      [1, 2, 3].permutation.each do |ary|
        result = sort ary.dup
        expect(result).to eq([1, 2, 3]),
          "#{ary.inspect} sorted to #{result.inspect}"
      end
    end

    it 'sorts a list with 10 elements' do
      5.times do
        ary    = [*1..10]
        result = sort ary.dup
        expect(result).to eq([*1..10]), "#{ary.inspect} sorted to #{result.inspect}"
      end
    end

    it 'sorts a list with nonconsecutive elements' do
      expect(sort [100, 5, 3, 19, 45]).to eq [3, 5, 19, 45, 100]
    end

    it 'sorts a list with equivalent elements' do
      expect(sort [1,5,3,5,3,1]).to eq [1,1,3,3,5,5]
    end

    it 'accepts a block to use for comparison' do
      pending() if pending.include? :block_comparison
      ary    = [*1..100].shuffle
      result = sort(ary.dup) { |l, r| -(l<=>r) }
      expect(result).to eq([*1..100].reverse),
        "reverse sorted #{ary.inspect}\n\nit came out as\n\n#{result.inspect}"
    end

    it 'sorts any comparable type' do
      expect(sort %w(c a b)).to eq %w(a b c)
    end

    it 'sorts large lists' do
      result = sort [43, 6, 19, 78, 74, 37, 88, 75, 73, 13, 61, 45, 40, 41, 82, 81, 48, 56, 3, 67, 69, 16, 55, 36, 47, 86, 62, 28, 51, 24, 14, 65, 59, 96, 70, 52, 29, 50, 57, 2, 20, 98, 89, 9, 44, 72, 60, 94, 4, 91, 1, 95, 38, 83, 23, 21, 35, 92, 33, 39, 84, 54, 11, 42, 71, 64, 8, 68, 85, 79, 7, 5, 77, 100, 10, 49, 30, 46, 34, 32, 99, 26, 66, 22, 80, 31, 17, 12, 18, 15, 63, 27, 90, 76, 53, 93, 87, 58, 25, 97]
      expect(result).to eq [*1..100]
    end

    if in_place
      it 'sorts the list in-place' do
        ary = [3,2,1]
        sort ary
        expect(ary).to eq [1,2,3]
      end
    else
      it 'does not mutate the original array' do
        ary = [3,2,1]
        sort ary
        expect(ary).to eq [3,2,1]
      end
    end
  end
end


require 'heap_linked'
assert_sorts HeapLinked, tag: :heap, in_place: false

require 'binary_search_tree'
assert_sorts BinarySearchTree, tag: :bst, in_place: false

require 'run_based_merge_sort'
assert_sorts RunBasedMergeSort, tag: :rbms, in_place: false, pending: :block_comparison
