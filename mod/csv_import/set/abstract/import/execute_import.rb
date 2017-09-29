event :import_csv, :integrate_with_delay, on: :update, when: :data_import? do
  import_manager.import_rows selected_row_indices
  redirect_to_import_status
end

event :prepare_import, :prepare_to_store, on: :update, when: :data_import? do
  import_status_card.reset selected_row_count
end

def import_manager
  @import_mananger =
    ActImportManager.new self, csv_file, conflict_strategy, extra_data
end

# @return [Hash] key is the row index.
#   example: { 1: { import: true, extra_data: {}, corrections: {} } }
def import_data
  @import_data ||=
    begin
      params = Env.params[:import_data] || {}
      params = params.to_unsafe_h if params.respond_to?(:to_unsafe_h)
      params.each_with_object({}) do |(k, v), h|
        h[(k.to_s.to_i rescue k)] = v
      end
    end
end

def conflict_strategy
  Env.params[:confict]&.to_sym || :skip
end

def extra_data
  # rearrange extra data hash from
  #  row_index: { extra_data: { ... } } to
  #  row_index: { ... }
  @extra_data ||=
    import_data.each_with_object({ all: { source_map: source_map } }) do |(key, value), options|
      options[key] = value[:extra_data]
    end
end

def source_map
  @source_map ||= {}
end

def data_import?
  import_data.present? && import_data.is_a?(Hash)
end

def redirect_target_after_import
  import_status_card.name
end

def redirect_to_import_status
  # abort :failure if errors.present?
  return unless (target = redirect_target_after_import)
  success << { name: target, redirect: true, view: :open }
end


def selected_row_count
  selected_row_indices.size
end

def selected_row_indices
  @selected_row_indices ||=
    import_data.each_with_object([]) do |(index, data), a|
      next unless data[:import]
      a << index.to_i
    end
end
