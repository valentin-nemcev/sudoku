#!/usr/bin/env ruby

require 'awesome_print'
require 'set'


problems = [
  # '935748621876231594124695783512469378643872915789153462267514839491386257358927146',
    '..5..8..187623159.......78....4.....64....9......53..2.6.........138..5735892714.',
  # '..5..8..18......9.......78....4.....64....9......53..2.6.........138..5....9.714.',
  # '..........72.6.1....51...82.8...13..4.........37.9..1.....238..5.4..9.........79.',
  # '...658.....4......12............96.7...3..5....2.8...3..19..8..3.6.....4....473..',
  # '.2.3.......6..8.9.83.5........2...8.7.9..5........6..4.......1...1...4.22..7..8.9',
  # '.5..9....1.....6.....3.8.....8.4...9514.......3....2..........4.8...6..77..15..6.',
  # '.....2.......7...17..3...9.8..7......2.89.6...13..6....9..5.824.....891..........',
  # '3...8.......7....51..............36...2..4....7...........6.13..452...........8..',
]

solutions = [
  '935748621876231594124695783512469378643872915789153462267514839491386257358927146',
  '143258679872964153695137482986541327451372968237896514719623845564789231328415796',
  '937658241864291735125734986583419627649372518712586493471963852396825174258147369',
  '924361758156478293837592641613247985749185326582936174498623517371859462265714839',
  '856491372143572698927368451278645139514923786639817245361789524485236917792154863',
  '659412378238679451741385296865723149427891635913546782396157824574268913182934567',
  '354186927298743615167952483481527369932614578576398241729865134845231796613479852',
]



class Problem
  attr_reader :cells, :boxes, :cols, :rows, :blank_indices
  def initialize(str_def)
    @cells = str_def.chars.map do |char|
      char.match(/\d/) ? char.to_i : nil
    end

    @is_correct = check

    sort_blank_indices
    advance_blank_index
  end

  def initialize_copy(other)
    @cells = other.cells.dup
    @blank_indices = other.blank_indices.dup
    @boxes = other.boxes.map(&:dup)
    @cols  = other.cols.map(&:dup)
    @rows  = other.rows.map(&:dup)
  end

  def to_s
    @cells.map{ |d| d.nil? ? '.' : d }.join
  end

  def solved?
    @blank_index.nil?
  end

  def correct?
    @is_correct
  end

  def sort_blank_indices
    cell_constraints = []
    @blank_indices = []
    @cells.each_with_index do |el, i|
      next unless el.nil?
      col, row, box = sets(i)
      cell_constraints << [col.length + row.length + box.length, i]
      @blank_indices << i
    end
    @blank_indices = cell_constraints.sort.map{ |c| c[1] }
    # ap cell_constraints.sort
  end

  def advance_blank_index
    # @blank_index = @cells.index(nil)
    @blank_index = @blank_indices.shift
  end

  SET_MAP = (0...9*9).map do |i|
    col_n = i % 9
    row_n = i / 9
    box_n = row_n / 3 * 3 + col_n / 3
    [col_n, row_n, box_n].freeze
  end.freeze

  def sets(i)
    col_n, row_n, box_n = SET_MAP[i]

    [@cols[col_n] ||= Set.new, @rows[row_n] ||= Set.new, @boxes[box_n] ||= Set.new]
  end

  def check
    @boxes = []
    @cols  = []
    @rows  = []
    @cells.each_with_index do |el, i|
      next if el.nil?
      col, row, box = sets(i)
      return false unless col.add?(el) &&
        row.add?(el) &&
        box.add?(el)
    end
    true
  end

  def fill_blanks
    @cells.each_with_index do |el, i|
      next unless el.nil?
      col, row, box = sets(i)
      if col.length == 8 && row.length == 8 && box.length == 8
        @cells[i] = ((1..9).to_set - col).first
        @blank_indices.delete(i)
        puts "filled #{i}"
      end
    end
  end

  def fill_blank(digit)
    @cells[@blank_index] = digit
    col, row, box = sets(@blank_index)
    # @is_correct = col.add?(digit) &&
    #   row.add?(digit) &&
    #   box.add?(digit)
    col << digit
    row << digit
    box << digit
    # @is_correct = check
    # fill_blanks if @is_correct
    # sort_blank_indices if @is_correct
    advance_blank_index
  end

  DIGITS = (1..9).to_set.freeze

  def solve
    return nil unless correct?
    return self if solved?
    col, row, box = sets(@blank_index)
    (DIGITS - (col | row | box)).each do |d|
    # (1..9).each do |d|
      candidate = self.dup
      candidate.fill_blank(d)
      possible_solution = candidate.solve
      return possible_solution unless possible_solution.nil?
    end
    return nil
  end
end


(problems).each do |problem|
  puts problem
  solution = Problem.new(problem).solve
  puts solution ? solution.to_s : '---'
  ap solution.check if solution
  puts
end
