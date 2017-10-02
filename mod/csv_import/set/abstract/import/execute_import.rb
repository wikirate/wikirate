event :import_csv, :integrate_with_delay, on: :update, when: :data_import? do
  import_manager.import_rows selected_row_indices
  redirect_to_import_status
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
  @extra_data ||= Env.params[:extra_data].is_a?(Hash) ? Env.params[:extra_data] : {}
end

def data_import?
  Env.params[:import_rows].present? && Env.params[:import_rows].is_a?(Hash)
end

def selected_row_count
  selected_row_indices.size
end

def selected_row_indices
  return [] unless (rows = Env.params[:import_rows])
  @selected_row_indices ||=
    rows.each_with_object([]) do |(index, value), a|
      next unless value == true || value == "true"
      a << index.to_i
    end
end

def redirect_target_after_import
  import_status_card.name
end

def redirect_to_import_status
  # abort :failure if errors.present?
  return unless (target = redirect_target_after_import)
  success << { name: target, redirect: true, view: :open }
end
