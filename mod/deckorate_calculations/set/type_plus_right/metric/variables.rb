# Metric variables (+:variable fields on metric cards) are lists of hashes stored
# as JSON
#
# Each item hash can have the following keys:
#  # All metric types
#  - metric:         # required. stored as id prefixed by tilde
#
#  # WikiRatings only
#  - weight          # used as item's weight in weighted average
#
#  # Formula only
#  - name            # the variable name used in scores
#  - unknown
#  - not_researched
#  - year
#  - company
#
#  Note: Scores do not maintain variable cards, because the only variable is the
#  metric being scored (which can be inferred from the left_id)

include_set Abstract::Pointer
include_set Abstract::IdPointer
include_set Abstract::MetricChild, generation: 1
include_set Abstract::CalcTrigger

delegate :metric_type_codename, to: :metric_card

event :validate_variables, :validate, on: :save, changed: :content do
  item_ids.each do |card_id|
    errors.add "unknown id: #{card_id}" unless (card = card_id.card)
    errors.add "not a metric: #{card.name}" unless card.type_id == MetricID
  end
end

def check_json_syntax
  self.content = content # trigger standardization
  super
end

def standardize_content content
  # make sure we have a list of hashes
  items = content_to_hash_list content
  # make sure each item/hash has a metric id
  items.each { |hash| hash["metric"] = standardize_item hash["metric"] }
  items.to_json
end

def item_strings _args={}
  parse_content.map { |item_hash| item_hash["metric"] }
end

def hash_list
  # @hash_list ||=
  parse_content.map(&:symbolize_keys!)
end

def export_content
  db_content
end

def input_array
  (content.present? ? parse_content : [])
end

private

def content_to_hash_list content
  case content
  when Array
    content
  when /^\s*\[/
    JSON.parse content
  else
    items_from_simple content
  end
end

def items_from_simple content
  content.to_s.split(/\n+/).map.with_index do |variable, index|
    { "metric" => variable, "name" => "m#{index + 1}" }
  end
end

format :html do
  delegate :metric_type_codename, to: :card

  view :core do
    render :"#{metric_type_codename}_core"
  end

  view :input do
    card.check_json_syntax
    super()
  end

  def input_type
    metric_type_codename
  end

  def filtered_item_view
    send "#{metric_type_codename}_filtered_item_view"
  end

  def filtered_item_wrap
    send "#{metric_type_codename}_filtered_item_wrap"
  end

  def default_item_view
    :bar
  end

  def filter_card
    :metric.card
  end

  def custom_variable_input template
    with_nest_mode :normal do
      haml template
    end
  end

  def filtered_item_duplicable
    metric_type_codename == :formula
  end
end
