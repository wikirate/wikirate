class CSVRow
  include ::Card::Model::SaveHelper

  @required = []

  class << self
    attr_reader :required
  end

  def initialize row
    @row = row
    self.class.required.each do |key|
      raise StandardError, "value for #{key} missing" unless row[key].present?
    end
  end
end
