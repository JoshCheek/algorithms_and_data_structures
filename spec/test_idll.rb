gem 'minitest', '~> 5.0'
require 'minitest/autorun'
require 'minitest/pride'

require_relative '../ds&a/idll'

class TestIdll < Minitest::Spec
  let(:list) { IDLL.new }

  describe '#to_a' do
    it '#to_a converts the list to an array' do
      assert_equal [], list.to_a
    end
  end

  describe '#prepend(data)' do
    it 'returns a list with data placed at its front' do
      assert_equal [1, 2], list.prepend(2).prepend(1).to_a
    end

    it 'does not mutate the list' do
      list.prepend(1)
      assert_equal [], list.to_a
    end
  end

  describe '#append(data)' do
    it 'returns a list with data placed at its end' do
      assert_equal [2, 1], list.append(2).append(1).to_a
    end

    it 'does not mutate the list' do
      list.append(1)
      assert_equal [], list.to_a
    end
  end

  describe '#f_each' do
    it 'iterates through the list from the front' do
      seen = []
      list.append(1).append(2).f_each { |n| seen << n }
      assert_equal [1, 2], seen
    end

    it 'returns an enum when no block is provided' do
      assert_equal [2, 4], list.append(1).append(2).f_each.map { |n| n * 2 }
    end
  end

  describe '#b_each' do
    it 'iterates through the list from the back' do
      seen = []
      list.append(1).append(2).b_each { |n| seen << n }
      assert_equal [2, 1], seen
    end

    it 'returns an enum when no block is provided' do
      assert_equal [4, 2], list.append(1).append(2).b_each.map { |n| n * 2 }
    end
  end

  describe 'edge cases' do
    specify 'more complex prepend and append interaction' do
      list34     = list.prepend(3).append(4)
      list123456 = list34.append(5).append(6).prepend(2).prepend(1)
      list3498   = list34.append(9).append(8)
      assert_equal [],                 list.to_a
      assert_equal [3, 4],             list34.to_a
      assert_equal [1, 2, 3, 4, 5, 6], list123456.to_a
      assert_equal [3, 4, 9, 8],       list3498.to_a
    end
  end



  describe 'cursors' do
    let(:list1to4) { list.append(3).prepend(2).append(4).prepend(1) }
    let(:fcrs)     { list1to4.f_cursor }
    let(:bcrs)     { list1to4.b_cursor }

    describe '#f_cursor' do
      it 'provides a cursor before the front of the list' do
        assert_equal 1, fcrs.next_data
      end
    end

    describe '#b_cursor' do
      it 'provides a cursor after the end of the list' do
        assert_equal 4, bcrs.prev_data
      end
    end

    specify 'can move through the list' do
      assert_equal 1, fcrs.next_data
      assert_equal 2, fcrs.succ.next_data
      assert_equal 1, fcrs.next_data
      assert_equal 4, fcrs.succ.succ.succ.next_data
      assert_equal 1, fcrs.next_data
      assert_equal 3, fcrs.succ.succ.succ.pred.pred.succ.next_data
    end

    specify 'are zero-width, knowing the data before and after them' do
      assert_equal 1, fcrs.succ.prev_data
      assert_equal 2, fcrs.succ.next_data
    end

    specify 'know when they are at the front/back' do
      assert_predicate IDLL.new.f_cursor, :at_front?
      assert_predicate IDLL.new.f_cursor, :at_back?

      crs = fcrs      # | 1 2 3 4
      assert_predicate crs, :at_front?
      refute_predicate crs, :at_back?
      crs = crs.succ # 1 | 2 3 4
      refute_predicate crs, :at_front?
      refute_predicate crs, :at_back?
      crs = crs.succ # 1 2 | 3 4
      refute_predicate crs, :at_front?
      refute_predicate crs, :at_back?
      crs = crs.succ # 1 2 3 | 4
      refute_predicate crs, :at_front?
      refute_predicate crs, :at_back?
      crs = crs.succ # 1 2 3 4 |
      refute_predicate crs, :at_front?
      assert_predicate crs, :at_back?
      crs = crs.pred # 1 2 3 | 4
      refute_predicate crs, :at_front?
      refute_predicate crs, :at_back?
      crs = crs.pred.pred.pred # | 1 2 3 4
      assert_predicate crs, :at_front?
      refute_predicate crs, :at_back?
    end

    specify 'can return a list' do
      assert_equal IDLL, fcrs.to_list.class
      assert_equal [1,2,3,4], fcrs.to_list.to_a
      assert_equal [1,2,3,4], bcrs.to_list.to_a
      assert_equal [1,2,3,4], bcrs.pred.pred.to_list.to_a
    end

    specify 'can insert items before or after them' do
      crs = IDLL.new.f_cursor

      assert_predicate crs, :at_front?
      refute_predicate crs.insert_before(1), :at_front?
      assert_predicate crs.insert_before(1), :at_back?
      assert_predicate crs, :at_front?

      assert_predicate crs, :at_back?
      assert_predicate crs.insert_after(1), :at_front?
      refute_predicate crs.insert_after(1), :at_back?
      assert_predicate crs, :at_back?

      assert_equal [0, 1, 2, 2.1, 2.2, 3, 4, 5],
                   fcrs.insert_before(0)
                       .succ # 1|2
                       .succ # 2|3
                       .insert_after(2.2)
                       .insert_before(2.1)
                       .succ # 2.2|3
                       .succ # 3|4
                       .succ # 4|
                       .insert_after(5)
                       .to_list
                       .to_a

      assert_equal [1,2,3,4], fcrs.to_list.to_a
    end
  end
end
