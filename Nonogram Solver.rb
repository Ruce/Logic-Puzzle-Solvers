# Nonogram Solver
# By Bruce Cheung

require 'set'

def print(row)
	print_row = "["
	row.each_with_index do |j, i|
		print_row << "#{j}"
		print_row << "," unless i == row.count - 1
	end
	print_row << "]"
	
	puts print_row
end

def row_checker(rule, row)
	# First, if the sum of the rule is different from the row, the row fails
	if rule.inject(:+) != row.inject(:+)
		return false
	end
	
	# Run through the rule and sequentially check for errors
	row_break = 0
	rule.each do |n|
		current_rule = 0
		
		row.each_with_index do |j, i|
			next if i < row_break
			
			if j == 1
				current_rule += 1
			elsif current_rule != 0 # and j == 0 (redundant check)
				row_break = i
				return false if current_rule != n
				break
			end
		end
		
		return false if current_rule != n
	end
	
	return true
end

def get_column(grid, k) # ZERO indexed
	column = []
	grid.each do |row|
		column << row[k]
	end
	return column
end

def generate_row(rule, row_fixed_ones, row_fixed_zeroes, k)
	all_rows = [[]]
	min_size = rule.inject(:+) + rule.count - 1
	dof = k - min_size # "degrees of freedom": number of spare slots
	remaining_elements = min_size # minimum size still needed after adding some elements
	
	if dof < 0
		puts "ERROR: Rule has more elements than size of grid allows"
		exit
	end
		
	rule.each_with_index do |n, i|
		current_row_count = all_rows.count
		
		current_row_count.times do |c|
			row = all_rows[c]
			dof_left = k - remaining_elements - row.count
			
			(dof_left + 1).times do |d|
				possible_row = row + Array.new(d, 0)
				possible_row << 0 unless i == 0
				n.times {possible_row << 1}

				all_rows << possible_row
			end
		end
		all_rows = all_rows.drop(current_row_count)
		
		remaining_elements -= n
		remaining_elements -= 1 unless i == 0
	end
	
	all_rows.each_with_index do |row, c|
		space_left = k - row.count
		space_left.times {row << 0}
						
		row_fixed_ones.each do |p|		# If position p has a 0, row is invalid
			if row[p] == 0
				row = nil
				break
			end
		end
		
		unless row.nil?
			row_fixed_zeroes.each do |p|	# If position p has a 0, row is invalid
				if row[p] == 1
					row = nil
					break
				end
			end
		end
		
		all_rows[c] = row
	end
	
	return all_rows.compact
end

## Inputs

## 25x25 GCHQ
RULES_ROW = [[7,3,1,1,7], [1,1,2,2,1,1], [1,3,1,3,1,1,3,1], [1,3,1,1,6,1,3,1], [1,3,1,5,2,1,3,1], [1,1,2,1,1], [7,1,1,1,1,1,7], [3,3], [1,2,3,1,1,3,1,1,2], [1,1,3,2,1,1], [4,1,4,2,1,2], [1,1,1,1,1,4,1,3], [2,1,1,1,2,5], [3,2,2,6,3,1], [1,9,1,1,2,1], [2,1,2,2,3,1], [3,1,1,1,1,5,1], [1,2,2,5], [7,1,2,1,1,1,3], [1,1,2,1,2,2,1], [1,3,1,4,5,1], [1,3,1,3,10,2], [1,3,1,1,6,6], [1,1,2,1,1,2], [7,2,1,2,5]]
RULES_COLUMN = [[7,2,1,1,7], [1,1,2,2,1,1], [1,3,1,3,1,3,1,3,1], [1,3,1,1,5,1,3,1], [1,3,1,1,4,1,3,1], [1,1,1,2,1,1], [7,1,1,1,1,1,7], [1,1,3], [2,1,2,1,8,2,1], [2,2,1,2,1,1,1,2], [1,7,3,2,1], [1,2,3,1,1,1,1,1], [4,1,1,2,6], [3,3,1,1,1,3,1], [1,2,5,2,2], [2,2,1,1,1,1,1,2,1], [1,3,3,2,1,8,1], [6,2,1], [7,1,4,1,1,3], [1,1,1,1,4], [1,3,1,3,7,1], [1,3,1,1,1,2,1,1,4], [1,3,1,4,3,3], [1,1,2,2,2,6,1], [7,1,3,2,1,1]]
GRID_SIZE = 25

## 25x25 ID: 526,605
#RULES_ROW = [[4,2,2], [6,2,2], [5,1], [4,1,1], [6,2], [1,4,2,6,2], [1,3,4,5,1], [2,3,11], [2,8], [7,2,2,1], [4,1,5,1], [3,1,6], [2,8], [3,4,1,1,1], [2,3,2,4], [2,2,1,1,4], [2,3,1,2,1,1], [4,15], [2,12,1], [6,1,3,2,5], [7,1,2,2], [6,6,5], [3,10,3,4], [7,8,5], [3,3,6,4]]
#RULES_COLUMN = [[4,5,1,3], [11,5], [1,3,1,1,5], [3,7,1], [1,3,1,1,10], [7,1,1,2,6], [8,1,6], [7,3,1,1], [3,1,4,4], [3,1,1,5,1,2], [3,5,3,3], [9,2,4], [7,8], [2,1,3,8], [2,1,6,2], [1,2,2,3], [1,3,3,3], [2,5,3,2], [2,4,3], [3,4], [3,1,5,1], [2,11], [3,1,1,4], [2,2,6,4], [7,2,2,1,4]]
#GRID_SIZE = 25

## 25x25 ID: 8,650,562
#RULES_ROW = [[1,3,7], [3,7], [1,7], [3,2,3,3], [3,7,2,1], [3,6,2], [3,5,1], [3,3,5], [3,2,1,4], [3,3,1,3], [1,6,4], [1,1,9], [2,2,8,2], [2,6,1,9,1], [3,3,10], [3,5,2], [3,4], [2,1,1,5,2], [4,7,2], [4,8,4], [4,8,4], [11,1,6], [10,1,3], [7,1,4,3], [7,2,6,3]]
#RULES_COLUMN = [[7,10], [6,10,2], [6,3,7], [8], [1,1,4], [1,3,1,4], [4,1,4,4], [8,3,8], [8,2,5], [5,1,1,1,6], [7,2,8], [2,4,6,3], [2,1,4,7,1], [2,11], [5,4,2,1], [3,2,5,1], [2,1,9,2], [2,8,2], [3,7,1,2], [3,2,4], [3,2,3], [3,2,5], [4,1,8], [2,2,6], [3,3]]
#GRID_SIZE = 25

## 10x10
#RULES_ROW = [[2,3], [1,1,3], [1,5], [1,3], [2], [3], [3], [5], [6, 2], [2, 7]]
#RULES_COLUMN = [[5], [1,5], [1,5], [5,3], [3], [2,2], [2,1], [4,1], [3,2], [3,2]]
#GRID_SIZE = 10

## 15x15
#RULES_ROW = [[3,2], [4], [3,3], [3,4], [5,1], [5,1], [8,3], [2,1,1,1], [4,4,3], [2,1,4,3], [4,5], [2,4,1], [1,2,3], [2,2,6], [3,2,5]]
#RULES_COLUMN = [[2,3,3], [2,4,2], [2,1,1,1], [1,5], [1,3,3], [1,3,6], [3,2], [3,3], [5], [2,4], [4,7], [4,5], [4,7,2], [1,1,1,3,2], [1,4,1]]
#GRID_SIZE = 15

## Test Grid
# [1,0,0,1]
# [0,1,1,0]
# [1,1,0,1]
# [1,0,0,0]
#RULES_ROW = [[1,1], [2], [2,1], [1]]
#RULES_COLUMN = [[1,2], [2], [1], [1,1]]
#GRID_SIZE = 4

@all_possible_rows = []
@all_possible_columns = []
@fixed_ones = Array.new(GRID_SIZE) {Set.new()}
@fixed_zeroes = Array.new(GRID_SIZE) {Set.new()}

def calculate_rows()
	@all_possible_rows = []
	RULES_ROW.each_with_index do |rule_row, r|
		@all_possible_rows << generate_row(rule_row, @fixed_ones[r], @fixed_zeroes[r], GRID_SIZE)		# [ [ [row1a],[row1b] ] , [ [row2a] ] , [ [row3a],[row3b] ] ]
	end
	
	row_possible_combinations = 1
	
	@all_possible_rows.each_with_index do |row, r|
		row_possible_combinations *= row.count
		
		# Checking for positions that are always fixed to 1
		GRID_SIZE.times do |p|
			is_one = true
			is_zero = true
			row.each do |possible_row|
				if possible_row[p] == 0
					is_one = false
				else
					is_zero = false
				end
			end

			if is_one then @fixed_ones[r] << p end
			if is_zero then @fixed_zeroes[r] << p end
		end
	end
	
	puts "Possible row combinations: #{row_possible_combinations}"
end

def calculate_columns()
	@all_possible_columns = []
	RULES_COLUMN.each_with_index do |rule_col, c|
		fixed_ones_column = []
		@fixed_ones.each_with_index do |row, r|
			if row.include?(c) then fixed_ones_column << r end
		end
		
		fixed_zeroes_column = []
		@fixed_zeroes.each_with_index do |row, r|
			if row.include?(c) then fixed_zeroes_column << r end
		end
		
		@all_possible_columns << generate_row(rule_col, fixed_ones_column, fixed_zeroes_column, GRID_SIZE)
	end
	
	column_possible_combinations = 1
	
	@all_possible_columns.each_with_index do |col, c|
		column_possible_combinations *= col.count
		
		GRID_SIZE.times do |p|
			is_one = true
			is_zero = true
			col.each do |possible_col|
				if possible_col[p] == 0
					is_one = false
				else
					is_zero = false
				end
			end
			if is_one then @fixed_ones[p] << c end
			if is_zero then @fixed_zeroes[p] << c end
		end
	end
	
	puts "Possible column combinations: #{column_possible_combinations}"
end

7.times do |t|
	puts "Run #{t+1}"
	calculate_rows()
	calculate_columns()
	puts "\r\n"
end

calculate_rows()
puts "\r\nFinal fixed positions:"
@fixed_ones.each {|fixed_row| print(fixed_row)}
puts "\r\n"

# RETURNS e.g. [ [ [1,0,0], [0,1,0] ] , [ [1,0,0], [0, 0, 1] ] ]
def get_possible_grids(all_possible_rows, ln) # Parse all combinations of line ln with the next line (recursive)
	all_grids = []
	
	if ln == all_possible_rows.count - 1
		all_possible_rows[ln].each {|next_row| all_grids << [next_row]}
	else	
		next_line_grids = get_possible_grids(all_possible_rows, ln + 1)
		
		all_possible_rows[ln].each do |row|
			next_line_grids.each do |next_grid|		# [ [row2], [row3] ]
				new_grid = [row]					# [ [row1] ]
				next_grid.each {|next_row| new_grid << next_row}
				all_grids << new_grid
			end
		end
	end
	
	return all_grids
end

all_possible_grids = get_possible_grids(@all_possible_rows, 0)

all_possible_grids.each_with_index do |grid, g|
	## Input validation
	size = RULES_ROW.count
	if size != RULES_COLUMN.count
		puts "ERROR: Number of row and column rules do not match!"
		exit
	elsif size != grid.count
		puts "ERROR: Number of rows in grid does not match with number of rules!"
		exit
	end
	grid.each do |row|
		if row.count != size
			puts "ERROR: Number of columns in grid does not match with number of rules!"
			exit
		end
	end

	## Start checking grid against rules
	result = true
	size.times do |k|
		row_result = row_checker(RULES_ROW[k], grid[k])
		column_result = row_checker(RULES_COLUMN[k], get_column(grid, k))
		result = result & row_result
		result = result & column_result
		
		#puts "Row #{k}: #{row_result}. Column #{k}: #{column_result}."
	end
	#puts "Overall validity: #{result}\r\n\r\n"
	
	if result
		puts "Grid #{g+1}:"
		grid.each {|row| print(row)}
	end
end
