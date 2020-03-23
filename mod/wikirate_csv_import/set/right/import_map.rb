# mapping of all uniq values in each mapped column
#
# {
#   column1 => { val1 => card1.id,
#                val2 => card2.id,... },
#   column2 => { val3 => card3.id,... }, ...
# }
#
#

delegate :csv_row_class, :csv_file, to: :left

def generate_exact!
  self.content = exact_match_map.to_json
end

def exact_match_map
  csv_row_class.map_columns.each_with_object({}) do |map_column, map|
    column_map = map[map_column] = {}
    csv_file.each_row_hash do |row_hash|
      map_exact_for row_hash[map_column], column_map
    end
  end
end

def map_exact_match_for val, map
  return if map.key? val
  map[val] = Card.fetch_id val
end

def map
  @map ||= JSON.parse(content).symbolize_keys
end

