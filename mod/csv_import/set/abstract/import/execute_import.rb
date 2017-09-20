# the is_data_import flag distinguishes between an update of the
# import file and importing the file
event :import_csv, :prepare_to_store, on: :update, when: :data_import? do
  return unless valid_import_data?

  with_success_params do
    each_import_row  do |csv_row|
      process_row csv_row
    end
  end
  handle_redirect
end

def process_row csv_row
  csv_row.execute_import as_subcard_of: self, duplicates: :report
rescue ImportError, InvalidData => _e
  handle_import_errors csv_row
end

def source_map
  @source_map ||= {}
end

def corrections index
  import_data[index][:corrections]
end

def extra_data index
  import_data[index][:extra_data].merge source_map: source_map
end

def import_data
  @import_data ||= Env.params[:import_data]
end

def data_import?
  import_data.present?
end

def valid_import_data?
  import_data.is_a? Hash
end

def redirect_target_after_import
  nil
end

def handle_redirect
  abort :failure if errors.present?
  return unless (target = redirect_target_after_import)
  success << { name: target, redirect: true, view: :open }
end

def handle_import_errors csv_row
  csv_row.errors.each do |_key, msg|
    errors.add "import error (row #{csv_row.row_index})", msg
  end
end

def each_import_row
  csv_file.each_row selected_row_indices do |row_hash, index|
    yield csv_row_class.new row_hash, index, corrections(index), extra_data(index)
  end
end

def selected_row_indices
  import_data.each_with_object([]) do |(index, data), a|
    next unless data[:import]
    a << index
  end
end
