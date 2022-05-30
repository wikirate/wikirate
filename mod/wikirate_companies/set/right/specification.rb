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
include_set Card::Set::TypePlusRight::Metric::MetricAnswer

attr_accessor :metric_card

# store explicit list in `<Company Group>+company`
def explicit?
  content == "explicit"
end

def implicit?
  !explicit?
end

def constraints
  raw_constraints.map do |raw_constraint|
    SubjConstraint.new_from_raw raw_constraint
  end
end

# Each constraint is a CSV row
def raw_constraints
  explicit? ? [] : content.split(/\n+/).map(&:strip)
end

format do
  # OVERRIDES of MetricCompanyFilter
  # ignore filter params
  def filter_hash
    {}
  end

  def default_filter_hash
    {}
  end
end

format :json do
  def molecule
    super.merge constraints: constraints
  end

  def constraints
    card.constraints.map do |c|
      {
        metric: c.metric.name,
        year: c.year,
        value: c.value,
        group: c.group
      }
    end
  end

  view(:items) { [] }
end
