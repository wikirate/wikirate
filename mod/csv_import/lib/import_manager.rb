# ImportManager coordinates the import of a CSVFile. It defines the conflict and error
# policy. It collects all errors and provides extra data like corrections for row fields.
class ImportManager
  require_dependency "import_manager/status"

  attr_reader :conflict_strategy

  def initialize csv_file, conflict_strategy = :skip, extra_data = {}
    @csv_file = csv_file
    @conflict_strategy = conflict_strategy
    @extra_data = integerfy_keys(extra_data || {})

    @extra_data[:all] ||= {}
    init_import_status
    @imported_keys = ::Set.new
  end

  def import row_indices = nil
    import_rows row_indices
  end

  def import_rows row_indices
    row_count = row_indices ? row_indices.size : @csv_file.row_count
    @import_status = ImportManager::Status.new counts: { total: row_count }

    @csv_file.each_row self, row_indices do |csv_row|
      #handle_import csv_row do
        csv_row.execute_import
      #end
    end
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

  def check_for_duplicates name
    key = name.to_name.key
    if @imported_keys.include? key
      report :duplicate_in_file, name
      throw :skip_row, :skipped
    else
      @imported_keys << key
    end
  end

  def with_conflict_strategy strategy
    tmp_cs = @conflict_strategy
    @conflict_strategy = strategy if strategy
    yield
  ensure
    @conflict_strategy = tmp_cs
  end

  def handle_conflict name, strategy: nil
    with_conflict_strategy strategy do
      if (@dup = duplicate(name))
        if @conflict_strategy == :skip
          throw :skip_row, :skipped
        elsif @conflict_strategy == :skip_card
          return @dup
        else
          @status = :overridden
        end
      end
      yield
    end
  end

  def duplicate name
    Card[name]
  end

  def log_status
    @import_status[@current_row.status][@current_row.row_index] = @current_row.name
    @import_status[:counts].step @current_row.status
  end

  # used by {CSVRow} objects
  def report_error msg
    @import_status[:errors][@current_row.row_index] << msg
  end

  def report key, msg
    case key
    when :duplicate_in_file
      msg = "#{msg} duplicate in this file"
    end
    @import_status[:reports][@current_row.row_index] << msg
  end

  def errors_by_row_index
    @import_status[:errors].each do |index, msgs|
      yield index, msgs
    end
  end

  def pick_up_card_errors card = nil
    card = yield if block_given?
    if card
      card.errors.each do |error_key, msg|
        report_error "#{card.name} (#{error_key}): #{msg}"
      end
      card.errors.clear
    end
    card
  end

  def errors? row = nil
    if row
      @import_status[:errors][row.row_index].present?
    else
      @import_status[:errors].values.flatten.present?
    end
  end

  def errors row=nil
    if row
      @import_status[:errors][row.row_index]
    else
      @import_status[:errors]
    end
  end

  def error_list
    @import_status[:errors].each_with_object([]) do |(index, errors), list|
      next if errors.empty?
      list << "##{index + 1}: #{errors.join("; ")}"
    end
  end

  def override?
    @conflict_strategy == :override
  end

  private

  def init_import_status
    @import_status = ImportManager::Status.new(@csv_file&.row_count || 0)
  end

  def specify_success_status status
    return status if status.in? %i[failed skipped]
    @status == :overridden ? :overriden : :imported
  end


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
