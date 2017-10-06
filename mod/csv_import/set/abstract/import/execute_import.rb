event :import_csv, :integrate_with_delay, on: :update, when: :data_import? do
  import_manager.import_rows selected_row_indices
end

event :flag_as_import, :prepare_to_validate, on: :update, when: :data_import? do
  @empty_ok = true
end

event :prepare_import, :prepare_to_store, on: :update, when: :data_import? do
  import_status_card.reset selected_row_count
end

def import_manager
  @import_mananger =
    ActImportManager.new self, csv_file, conflict_strategy, extra_data
end

def conflict_strategy
  Env.params[:conflict_strategy]&.to_sym || :skip
end

def extra_data
  @extra_data ||= fetch_hash_from_params(:extra_data)
end

def fetch_hash_from_params key
  case Env.params[key]
    when Hash
      Env.params[key]
    when ActionController::Parameters
      Env.params[key].to_unsafe_h
    else
      {}
    end
end

def data_import?
  binding.pry
  Env.params[:import_rows].present?
end

def selected_row_count
  selected_row_indices.size
end

def selected_row_indices
  @selected_row_indices ||=
    fetch_hash_from_params(:import_rows).each_with_object([]) do |(index, value), a|
      next unless value == true || value == "true"
      a << index.to_i
    end
end
