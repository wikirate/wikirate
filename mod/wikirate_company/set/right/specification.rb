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

include_set Right::MetricCompanyFilter

# ignore filter params
def filter_hash
  {}
end

def default_filter_hash
  {}
end

def constraints
  raw_constraints.map do |raw_constraint|
    Constraint.new_from_raw raw_constraint
  end
end

event :validate_constraints, :validate, on: :save do
  standardize_constraint_csv
  err = constraint_error
  errors.add :content, "Invalid specifications: #{err}" if err
end

def standardize_constraint_csv
  return unless content.match? ";|;"

  self.content = js_generated_csv_to_array.map(&:to_csv).join
end

# The JavaScript generates a kind of half-way csv.
# The values are separated by ";|;" instead of ",".  This means that we don't
# have to deal with escaping commas, etc.
def js_generated_csv_to_array
  content.split("\n").map do |row|
    row_array = row.split ";|;"
    row_array[2] = serialized_value_to_json row_array[2]
    row_array
  end
end

# The JavaScript handles doesn't get into interpreting the answer value constraints
# Instead, it serializes them into a string like
# "filter%5Bvalue%5D%5Bfrom%5D=30&filter%5Bvalue%5D%5Bto%5D="
#
# This method interprets that string, plucks out the value we want, and generates
# json for it.
def serialized_value_to_json raw_value
  return unless raw_value.present?

  hash = Rack::Utils.parse_nested_query CGI.unescape(raw_value)
  hash.dig("filter", "value")&.to_json
end

def constraint_error
  constraints.each(&:validate!)
  false
rescue StandardError => e
  e.message
end

def raw_constraints
  explicit? ? [] : content.strip.split("\n")
end

# converts each "row" of a specification into a Constraint object
class Constraint
  attr_accessor :metric, :year, :value

  def self.new_from_raw raw_constraint
    new(*CSV.parse_line(raw_constraint))
  end

  def initialize metric, year, value=nil
    @metric = Card.cardish metric
    @year = year.to_s
    @value = interpret_value value
  end

  def interpret_value value
    if value.is_a? String
      parsed = JSON.parse value
      parsed.is_a?(Hash) ? parsed.symbolize_keys : parsed
    else
      value
    end
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
