require 'spec_helper'
require 'floodfill'

RSpec.describe 'floodfill' do
  def strip_heredoc(str)
    leading_whitespace = str.scan(/^\s*/).min_by(&:length)
    str.gsub /^#{leading_whitespace}/, ''
  end

  def assert_fill(input, output)
    input  = strip_heredoc input
    output = strip_heredoc output
    expect(Floodfill.call input).to eq output
  end

  it 'fills in a grid with the specified character' do
    assert_fill <<-INPUT, <<-OUTPUT
    1 1
    .
    0 0 x
  INPUT
    x
  OUTPUT

    assert_fill <<-INPUT, <<-OUTPUT
    1 1
    .
    0 0 y
  INPUT
    y
  OUTPUT
  end

  it 'fills at the specified location, from the upper left (0, 0)' do
    assert_fill <<-INPUT, <<-OUTPUT
    5 4
    .....
    #####
    #.#.#
    #####
    1 2 x
  INPUT
    .....
    #####
    #x#.#
    #####
  OUTPUT
  end

  it 'fills all adjacent (up/down/left/right) tiles with the same mark' do
    assert_fill <<-INPUT, <<-OUTPUT
    7 7
    #######
    #.#.#.#
    ###.###
    #.....#
    ###.###
    #.#.#.#
    #######
    3 3 x
  INPUT
    #######
    #.#x#.#
    ###x###
    #xxxxx#
    ###x###
    #.#x#.#
    #######
  OUTPUT

    assert_fill <<-INPUT, <<-OUTPUT
    7 7
    #######
    #.#.#.#
    ###.###
    #.....#
    ###.###
    #.#.#.#
    #######
    0 0 x
  INPUT
    xxxxxxx
    x.x.x.x
    xxx.xxx
    x.....x
    xxx.xxx
    x.x.x.x
    xxxxxxx
  OUTPUT
  end

  it 'does not fill diagonally' do
    assert_fill <<-INPUT, <<-OUTPUT
    3 3
    .#.
    #.#
    .#.
    1 1 x
  INPUT
    .#.
    #x#
    .#.
  OUTPUT
  end

  it 'can fill a space with the same character that is already there' do
    assert_fill <<-INPUT, <<-OUTPUT
    1 1
    .
    0 0 x
  INPUT
    x
  OUTPUT
  end

  it 'wraps the top around to the bottom' do
    assert_fill <<-INPUT, <<-OUTPUT
    1 3
    .
    #
    .
    0 0 x
  INPUT
    x
    #
    x
  OUTPUT
  end

  it 'wraps the bottom around to the top' do
    assert_fill <<-INPUT, <<-OUTPUT
    1 3
    .
    #
    .
    0 2 x
  INPUT
    x
    #
    x
  OUTPUT
  end

  it 'wraps the left around to the right' do
    assert_fill <<-INPUT, <<-OUTPUT
    3 1
    .#.
    0 0 x
  INPUT
    x#x
  OUTPUT
  end

  it 'wraps the right around to the left' do
    assert_fill <<-INPUT, <<-OUTPUT
    3 1
    .#.
    2 0 x
  INPUT
    x#x
  OUTPUT
  end

  it 'passes provided examples' do
    assert_fill <<-INPUT, <<-OUTPUT
    37 22
    .....................................
    ...#######################...........
    ...#.....................#...........
    ...#.....................#...........
    ...#.....................#...........
    ...#.....................#...........
    ...#.....................#...........
    ...#.....................#######.....
    ...###.................##......#.....
    ...#..##.............##........#.....
    ...#....##.........##..........#.....
    ...#......##.....##............#.....
    ...#........#####..............#.....
    ...#........#..................#.....
    ...#.......##..................#.....
    ...#.....##....................#.....
    ...#...##......................#.....
    ...#############################.....
    .....................................
    .....................................
    .....................................
    .....................................
    8 12 @
  INPUT
    .....................................
    ...#######################...........
    ...#.....................#...........
    ...#.....................#...........
    ...#.....................#...........
    ...#.....................#...........
    ...#.....................#...........
    ...#.....................#######.....
    ...###.................##......#.....
    ...#@@##.............##........#.....
    ...#@@@@##.........##..........#.....
    ...#@@@@@@##.....##............#.....
    ...#@@@@@@@@#####..............#.....
    ...#@@@@@@@@#..................#.....
    ...#@@@@@@@##..................#.....
    ...#@@@@@##....................#.....
    ...#@@@##......................#.....
    ...#############################.....
    .....................................
    .....................................
    .....................................
    .....................................
  OUTPUT
  end

  it 'passes provided examples' do
    assert_fill <<-INPUT, <<-OUTPUT
    16 15
    ----------------
    -++++++++++++++-
    -+------------+-
    -++++++++++++-+-
    -+------------+-
    -+-++++++++++++-
    -+------------+-
    -++++++++++++-+-
    -+------------+-
    -+-++++++++++++-
    -+------------+-
    -++++++++++++++-
    -+------------+-
    -++++++++++++++-
    ----------------
    2 2 @
  INPUT
    ----------------
    -++++++++++++++-
    -+@@@@@@@@@@@@+-
    -++++++++++++@+-
    -+@@@@@@@@@@@@+-
    -+@++++++++++++-
    -+@@@@@@@@@@@@+-
    -++++++++++++@+-
    -+@@@@@@@@@@@@+-
    -+@++++++++++++-
    -+@@@@@@@@@@@@+-
    -++++++++++++++-
    -+------------+-
    -++++++++++++++-
    ----------------
  OUTPUT
  end

  it 'passes provided examples' do
    assert_fill <<-INPUT, <<-OUTPUT
    9 9
    aaaaaaaaa
    aaadefaaa
    abcdafgha
    abcdafgha
    abcdafgha
    abcdafgha
    aacdafgaa
    aaadafaaa
    aaaaaaaaa
    8 3 ,
  INPUT
    ,,,,,,,,,
    ,,,def,,,
    ,bcd,fgh,
    ,bcd,fgh,
    ,bcd,fgh,
    ,bcd,fgh,
    ,,cd,fg,,
    ,,,d,f,,,
    ,,,,,,,,,
  OUTPUT
  end

  it 'passes provided examples' do
    assert_fill <<-INPUT, <<-OUTPUT
    9 9
    \\/\\/\\/\\.\\
    /./..././
    \\.\\.\\.\\.\\
    /.../.../
    \\/\\/\\/\\/\\
    /.../.../
    \\.\\.\\.\\.\\
    /./..././
    \\/\\/\\/\\.\\
    1 7 #
  INPUT
    \\/\\/\\/\\#\\
    /#/###/#/
    \\#\\#\\#\\#\\
    /###/###/
    \\/\\/\\/\\/\\
    /###/###/
    \\#\\#\\#\\#\\
    /#/###/#/
    \\/\\/\\/\\#\\
  OUTPUT
  end
end
