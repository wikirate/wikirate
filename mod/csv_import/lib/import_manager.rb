# ImportManager coordinates the import of a CSVFile. It defines the conflict and error
# policy. It collects all errors and provides extra data like corrections for row fields.
class ImportManager
  require_dependency "import_manager/status"
  include StatusLog
  include Conflicts

  attr_reader :conflict_strategy

  def initialize csv_file, conflict_strategy=:skip, extra_data={}
    @csv_file = csv_file
    @conflict_strategy = conflict_strategy
    @extra_data = integerfy_keys(extra_data || {})

    @extra_data[:all] ||= {}
    # init_import_status
    @imported_keys = ::Set.new
  end

  def import row_indices=nil
    import_rows row_indices
  end

  def import_rows row_indices
    row_count = row_indices ? row_indices.size : @csv_file&.row_count
    init_import_status row_count
    @csv_file.each_row self, row_indices, &:execute_import
  end

  def extra_data index
    (@extra_data[:all] || {}).deep_merge(@extra_data[index] || {})
  end

  def handle_import row
    @current_row = row
    status = catch(:skip_row) { yield }
    status = specify_success_status status
    @current_row.status = status
    log_status
    run_hook status
  end

  # used by csv rows to add additional cards
  def add_card args
    pick_up_card_errors do
      if @dup
        @dup.update_attributes args
        @dup
      else
        Card.create args
      end
    end
  end

  def add_extra_data index, data
    @extra_data[index].deep_merge! data
  end

  # add the final import card
  def import_card card_args
    @current_row.name = card_args[:name]
    check_for_duplicates card_args[:name]
    add_card card_args
  end

  private

  # methods like row_imported, row_failed, etc. can be used to add additional logic
  def run_hook status
    row_finished @current_row if respond_to? :row_finished
    hook_name = "row_#{status}".to_sym
    send hook_name, @current_row if respond_to? hook_name
  end

  def integerfy_keys hash
    hash.transform_keys { |key| key == :all ? :all : key.to_s.to_i }
  end
end
