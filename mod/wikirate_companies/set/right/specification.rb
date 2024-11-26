# Company Group specifications are stored in JSON that translates to the following format:
#
# [
#   { metrid_id: METRIC_ID1, year: YEAR1, value: VALUE1 },
#   { metrid_id: METRIC_ID2, year: YEAR2, value: VALUE2 },
#   ...
# ]
# Each item is a constraint

# we reuse metric and value interface from this set in the constraint editor:
include_set Card::Set::TypePlusRight::Metric::Answer

attr_accessor :metric_card

event :update_company_list, :prepare_to_store,
      on: :save, changed: :content, when: :implicit? do
  company_list.update_content_from_spec
end

event :validate_company_group_constraint, :validate,
      on: :save, changed: :content, when: :implicit? do
  constraints.each do |c|
    validate_constraint_metric c[:metric_id].to_i.card
    validate_constraint_year c[:year].to_s
  end
end

# store explicit list in `<Company Group>+company`
def explicit?
  content == "explicit"
end

def implicit?
  !explicit?
end

def constraints
  explicit? || content.blank? ? [] : JSON.parse(content).map(&:deep_symbolize_keys)
end

def each_reference_out
  constraints.each do |constraint|
    yield constraint[:metric_id].to_i.cardname, "L" # track as link
  end
end

def implicit_item_ids
  return [] unless implicit? && constraints.present?

  CompanyFilterCql # make sure company_answer attribute is loaded
  Card.search company_answer: constraints, return: :name
end

def standardize_content content
  return content if explicit?

  content = content_from_params if content_from_params.present?
  return content unless content.is_a? Array

  JSON standardize_content_array(content)
end

def content_from_params
  cont = Env.params.dig :filter, :company_answer
  cont = cont.values if cont && !cont.is_a?(Array)
  cont&.map { |c| Env.hash c }
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
    super.merge constraints: card.constraints
  end

  view(:items) { [] }
end

private

def standardize_content_array content
  content.map do |constraint|
    hash = Env.hash constraint
    ensure_metric_id hash
    hash
  end
end

def company_list
  left&.field :company
end

def validate_constraint_metric metric
  return if metric&.type_id == Card::MetricID

  errors.add :content, "invalid metric: #{metric}"
end

def validate_constraint_year year
  return if year.match(/^\d{4}$/) || year.in?(%w[any latest])

  errors.add :content, "invalid year: #{year}"
end

def ensure_metric_id constraint
  metric = constraint[:metric_id]
  constraint[:metric_id] = metric.number? ? metric.to_i : metric.card_id
end
