class CSVRow
  include ::Card::Model::SaveHelper

  @required = []
  @normalize = {}

  class << self
    attr_reader :required, :normalize
  end

  def initialize row
    @row = row
    self.class.required.each do |key|
      raise StandardError, "value for #{key} missing" unless row[key].present?
    end
    normalize
    validate
  end

  def normalize
    @row.each do |k, v|
      next unless (method = self.class.normalize[k])
      @row[k] = send method, v
    end
  end

  def validate
    @row.each do |k, v|
      validate_method = "validate_#{k}".to_sym
      next unless respond_to?(validate_method)
      send validate_method, v
    end
  end
end
