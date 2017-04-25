# Use CSVRow to process a csv row.
# CSVFile creates an instance of CSVRow for every row and calls #create on
# it.
class CSVRow
  include ::Card::Model::SaveHelper
  include Normalizer

  @columns = []
  @required = [] # array of required fields or :all
  @normalize = {} # Use column names as keys and method names as values.
                  # The normalize methods get the original field value as
                  # argument. The return value replaces the field value.
  @validate = {}  # Use column names as keys and method names as values.

  class << self
    def normalize key
      @normalize || @normalize[key]
    end

    def validate key
      @validate || @validate[key]
    end
  end

  def initialize row
    @row = row
    required.each do |key|
      raise StandardError, "value for #{key} missing" unless row[key].present?
    end
    normalize
    validate
  end

  def required
    self.class.required == :all ? columns : self.class_required
  end

  def columns
    self.class.columns
  end

  def normalize
    return unless self.class.normalize
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
    @row[k] = send method_name, value
  end

  def validate_field field, value
    return unless (method_name = method_name(field, :validate))
    send method_name, value
  end

  # @param type [:normalize, :validate]
  def method_name field, type
    method_name = "#{type}_#{field}".to_sym
    respond_to?(method_name) ? method_name : self.class.send(type, field)
  end
end
