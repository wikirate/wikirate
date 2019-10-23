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

# we reuse metric and value interface from this set in the constraint editor:
include_set Right::MetricCompanyFilter

# OVERRIDES of MetricCompanyFilter
# ignore filter params
def filter_hash
  {}
end

def default_filter_hash
  {}
end

# </OVERRIDES>

# store explicit list in `<Company Group>+company`
def explicit?
  content == "explicit"
end

def constraints
  raw_constraints.map do |raw_constraint|
    Constraint.new_from_raw raw_constraint
  end
end

# Each constraint is a CSV row
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
