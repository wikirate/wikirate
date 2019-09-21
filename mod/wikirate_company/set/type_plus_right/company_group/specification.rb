# Company Group specifications are stored in the following format:
#
# [[metric1_name]],year1,value_json1
# [[metric2_name]],year2,value_json2
#
# Each row represents a "constraint". No newlines. Any commas must be escaped.
#
# The "value json" is a one-line JSON string representing a valid AnswerQuery
# value for the answer's "value" field. See #value_query.
#
# Specification content is generated directly in JavaScript
# and is used in CompanyGroup+Company searches.

#
class Constraint
  attr_accessor :metric, :year, :value

  def self.new_from_raw raw_constraint
    new(*CSV.parse_line(raw_constraint))
  end

  def initialize metric, year, value=nil
    @metric = Card.cardish metric
    @year = year.to_s
    @value = value.is_a?(String) ? JSON.parse(value) : value
  end

  def to_s row_sep=nil
    ["[[#{metric.name}]]", year, value.to_json].to_csv(row_sep: row_sep)
  end

  def validate!
    raise "invalid metric" unless valid_metric?
    raise "invalid year" unless valid_year?
  end

  def valid_metric?
    metric&.type_id == MetricID
  end

  def valid_year?
    year.match(/^\d{4}$/) || year == "latest"
  end
end

event :validate_constraints, :validate, on: :save do
  err = constraint_error
  errors.add :content, "Invalid specifications: #{err}" if err
end

def constraint_error
  constraints.each(&:validate!)
  false
rescue StandardError => e
  e.message
end

def constraints
  raw_constraints.map do |raw_constraint|
    Constraint.new_from_raw raw_constraint
  end
end

def raw_constraints
  content.strip.split "\n"
end

format :html do
  def input_type
    :text_area
  end

  view :core, template: :haml
end
