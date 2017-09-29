def followable?
  false
end

def history?
  false
end

def already_imported? index
  imported_row_indices.include? index
end

def mark_as_imported row_index
  imported_rows_indices << row_index
  update_attributes content: imported_row_indices.join(",")
end

def imported_row_indices
  @imported_rows ||= ::Set.new content.split(",").map(&:to_i)
end
