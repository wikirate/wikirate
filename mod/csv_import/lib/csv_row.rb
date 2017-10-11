# Inherit from CSVRow to describe and process a csv row.
# CSVFile creates an instance of CSVRow for every row and calls #execute_import on it
class CSVRow
  include ::Card::Model::SaveHelper
  include Normalizer

  @columns = []
  @required = [] # array of required fields or :all

  # Use column names as keys and method names as values to define normalization
  # and validation methods.
  # The normalization methods get the original field value as
  # argument. The validation methods get the normalized value as argument.
  # The return value of normalize methods replaces the field value.
  # If a validate method returns false then the import fails.
  @normalize = {}
  @validate = {}

  class << self
    attr_reader :columns, :required

    def normalize key
      @normalize && @normalize[key]
    end

    def validate key
      @validate && @validate[key]
    end
  end

  attr_reader :errors, :row_index, :import_manager
  attr_accessor :status, :name

  delegate :add_card, :import_card, :override?, :pick_up_card_errors, to: :import_manager

  def initialize row, index, import_manager=nil
    @row = row
    @import_manager = import_manager || ImportManager.new(nil)

    @extra_data = @import_manager.extra_data(index)
    @corrections = @extra_data[:corrections]
    @corrections = {} unless @corrections.is_a? Hash
    merge_corrections

    @abort_on_error = true

    @row_index = index # 0-based, not counting the header line
  end

  def label
    label = "##{@row_index + 1}"
    label += ": #{@name}" if @name
    label
  end

  def merge_corrections
    @corrections.delete_if { |_k, v| v.blank? }
    @row.merge! @corrections
  end

  def execute_import
    @import_manager.handle_import(self) do
      prepare_import
      import
    end
  end

  def prepare_import
    collect_errors { check_required_fields }
    normalize
    collect_errors { validate }
  end

  def check_required_fields
    required.each do |key|
      error "value for #{key} missing" unless @row[key].present?
    end
  end

  def collect_errors
    @abort_on_error = false
    yield
    throw :skip_row, :failed if @import_manager.errors?(self)
  ensure
    @abort_on_error = true
  end

  def errors?
    @import_manager.errors? self
  end

  def errors
    @import_manager.errors self
  end

  def error msg
    @import_manager.report_error msg
    throw :skip_row, :failed if @abort_on_error
  end

  def required
    self.class.required == :all ? columns : self.class.required
  end

  def columns
    self.class.columns
  end

  def normalize
    @row.each do |k, v|
      normalize_field k, v
    end
  end

  def validate
    @row.each do |k, v|
      validate_field k, v
    end
  end

  def normalize_field field, value
    return unless (method_name = method_name(field, :normalize))
    @row[field] = send method_name, value
  end

  def validate_field field, value
    return unless (method_name = method_name(field, :validate))
    return if send method_name, value
    error "row #{@row_index + 1}: invalid value for #{field}: #{value}"
  end

  # @param type [:normalize, :validate]
  def method_name field, type
    method_name = "#{type}_#{field}".to_sym
    respond_to?(method_name) ? method_name : self.class.send(type, field)
  end

  def [] key
    @row[key]
  end

  def fields
    @row
  end

  def method_missing method_name, *args
    respond_to_missing?(method_name) ? @row[method_name.to_sym] : super
  end

  def respond_to_missing? method_name, _include_private = false
    @row.keys.include? method_name
  end
end
