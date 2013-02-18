#!/usr/bin/env ruby

require 'awesome_print'
require 'set'


problems = [
   # '935748621876231594124695783512469378643872915789153462267514839491386257358927146',
   # '9357486218762315.412469578.512469378643872915789153462267514839491386257358927146',
    # '..5..8..187623159.......78....4.....64....9......53..2.6.........138..5735892714.',
  # '..5..8..18......9.......78....4.....64....9......53..2.6.........138..5....9.714.',
  '..........72.6.1....51...82.8...13..4.........37.9..1.....238..5.4..9.........79.',
  # '...658.....4......12............96.7...3..5....2.8...3..19..8..3.6.....4....473..',
  # '.2.3.......6..8.9.83.5........2...8.7.9..5........6..4.......1...1...4.22..7..8.9',
  # '.5..9....1.....6.....3.8.....8.4...9514.......3....2..........4.8...6..77..15..6.',
  # '.....2.......7...17..3...9.8..7......2.89.6...13..6....9..5.824.....891..........',
  # '3...8.......7....51..............36...2..4....7...........6.13..452...........8..',
]

solutions = [
  # '935748621876231594124695783512469378643872915789153462267514839491386257358927146',
  '143258679872964153695137482986541327451372968237896514719623845564789231328415796',
  '937658241864291735125734986583419627649372518712586493471963852396825174258147369',
  '924361758156478293837592641613247985749185326582936174498623517371859462265714839',
  '856491372143572698927368451278645139514923786639817245361789524485236917792154863',
  '659412378238679451741385296865723149427891635913546782396157824574268913182934567',
  '354186927298743615167952483481527369932614578576398241729865134845231796613479852',
]



class Problem
  attr_reader :cells
  def initialize(str_def)
    @cells = (0...9*9).map do |i|
      (1..9).to_set
    end
    str_def.chars.each_with_index do |char, i|
      char.match(/\d/) and fill_cell(i, char.to_i)
    end
  end

  def initialize_copy(other)
    @cells = other.cells.map(&:dup)
  end

  def to_s
    @cells.map do |ds|
      case ds.length
      when 0 then 'x'
      when 1 then  ds.first
      else '.'
      end
    end.join
  end

  def solved?
    @cells.all?{ |ds| ds.length == 1 }
  end

  def correct?
    @cells.all?{ |ds| ds.length > 0 }
  end

  def fill_cell(cell_i, digit)
    related_indices(cell_i) do |i|
      @cells[i].delete(digit)
    end
    @cells[cell_i].replace([digit])
  end

  def related_indices(cell_i)
    col_n = cell_i % 9
    row_n = cell_i / 9
    box_r = row_n / 3
    box_c = col_n / 3
    9.times{ |i| yield i*9 + col_n }
    9.times{ |i| yield row_n*9 + i }
    3.times do |r|
      3.times do |c|
        yield (box_r*3 + r)*9 + (box_c*3 + c)
      end
    end
  end

  def find_next_cell
    @cells.each_with_index.inject(nil) do |minidx, (ds,i)|
      if ds.length <= 1
        minidx
      else
        minidx.nil? || (ds.length < @cells[minidx].length) ? i : minidx
      end
    end
    # @cells.index{ |ds| ds.length > 1 }
  end

  def solve
    # return self if solved? || !correct?
    cell_i = find_next_cell
    # ap cell_i
    return self if cell_i.nil?
    @cells[cell_i].each do |d|
      puts "#{' '*cell_i}#{d}\n#{self}"
      candidate = self.dup
      candidate.fill_cell(cell_i, d)
      if candidate.correct?
        next unless self.recheck
        solution = candidate.solve 
        return solution if solution.solved?
      end
    end
    self
  end

  def recheck
    rows = @cells.map{ |ds| ds.length == 1 ? ds.first : nil}.each_slice(9).to_a
    cols = rows.transpose
    blocks = rows.each_slice(3).flat_map do |rb|
      rb.transpose.each_slice(3).map(&:flatten)
    end
    # ap blocks
    (rows + cols + blocks).map(&:compact).all? { |r| r.uniq.length == r.length }
  end

end


(problems).zip(solutions).first(1).each do |problem, solution|
  puts problem
  puts s = Problem.new(problem).solve
  ap s.recheck
  puts solution
end
