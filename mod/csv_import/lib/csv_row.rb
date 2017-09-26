require_relative "csv_row/normalizer"

class ImportError < StandardError
end

class InvalidData < StandardError
end


# Use CSVRow to process a csv row.
# CSVFile creates an instance of CSVRow for every row and calls #import on it
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

  attr_reader :errors, :row_index
  delegate :add_card, :import_card, to: :import_manager

  def initialize row, index, import_manager, corrections=nil, extra_data=nil
    @row = row
    @import_manager = import_manager
    @corrections =
      if corrections
        corrections.delete_if { |_k, v| v.blank? }
        @row.merge! corrections
        corrections
      else
        {}
      end

    @abort_on_error = true
    @extra_data = extra_data || {}
    @row_index = index # 0-based, not counting the header line
    @errors = []
  end

  def execute_import as_subcard_of: nil, duplicates: :skip
    @act_card = as_subcard_of
    catch :skip_row do
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
    raise ImportError if @errors.present?
  ensure
    @abort_on_error = true
  end

  def error msg, type: :invalid_data
    @errors << msg
    @import_manager.add_error @row_index, msg, type
    raise ImportError, msg, caller if @abort_on_error
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
    raise InvalidData, @errors if @errors.present?
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
    #binding.pry
     respond_to_missing?(method_name) ? @row[method_name.to_sym] : super
  end

  def respond_to_missing? method_name, _include_private=false
    @row.keys.include? method_name
  end

  def pick_up_card_errors card=nil
    card = yield if block_given?
    if card
      card.errors.each do |error_key, msg|
        error "#{card.name} (#{error_key}): #{msg}"
      end
      card.errors.clear
    end
    card
  end
end
