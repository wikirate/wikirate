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

include_set Abstract::List
include_set Abstract::IdList
include_set Abstract::MetricChild, generation: 1
include_set Abstract::CalcTrigger

delegate :metric_type_codename, :score?, :rating?, to: :metric_card

event :validate_variables, :validate, on: :save, changed: :content do
  item_ids.each do |card_id|
    errors.add "unknown id: #{card_id}" unless (card = card_id.card)
    errors.add "not a metric: #{card.name}" unless card.type_id == MetricID
  end
end

event :variables_content_prep, :prepare_to_validate, on: :save do
  self.content = content # trigger standardization
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
  parsed = parse_content
  parsed.present? ? parsed.map(&:symbolize_keys!) : []
  # above is needed for special cases like headquarters location that have no input
  # metrics
end

def pod_content
  db_content
end

def input_array
  (content.present? ? parse_content : [])
end

# formulae can use the same metric for more than one variable
def unique_items?
  metric_type_codename != :formula
end

# def year_option?
#   hash_list.find { |h| h.key? :year }
# end
#
# def company_option?
#   hash_list.find { |h| h.key? :company }
# end

def unorthodox?
  hash_list.any? { |h| h.key?(:year) || h.key?(:company) }
end

def map_metric_and_context &block
  send "map_#{metric_type_codename}_metric_and_context", &block
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
  content.to_s.split(/\n+/).map { |var| { "metric" => var } }
end

format :data do
  view :core do
    card.parse_content
  end
end

format :html do
  delegate :metric_type_codename, :score?, :rating?, to: :card

  view :core do
    haml :core, preface: try("#{metric_type_codename}_preface")
  end

  view :input do
    if score?
      score_input
    else
      card.content = card.content # trigger standardization
      super()
    end
  end

  def input_type
    metric_type_codename
  end

  def filtered_item_view
    voo.items[:hide] = :bookmarks
    send "#{metric_type_codename}_filtered_item_view"
  end

  def filtered_item_wrap
    send "#{metric_type_codename}_filtered_item_wrap"
  end

  def filter_items_default_filter
    super.tap do |hash|
      hash.merge! metric_type: %w[Score WikiRating], name: "" if rating?
    end
  end

  def filter_items_modal_slot
    super.merge items: { view: :thumbnail }
  end

  def default_item_view
    :bar
  end

  def filter_card
    :metric.card
  end

  def custom_variable_input template
    with_nest_mode(:normal) { haml template }
  end

  # hacky. prevents new form from treating +variables as a subcard of +formula
  def edit_in_form_prefix
    card.new? ? "card[fields][:variables]" : super
  end

  private

  def metric_accordion
    accordion do
      card.map_metric_and_context do |metric, detail|
        metric_accordion_item metric, detail
      end
    end
  end

  def metric_accordion_item metric, detail
    metric.card.format.metric_accordion_item detail
  end
end
