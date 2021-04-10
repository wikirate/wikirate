# Answer search for a given Metric
STANDARD_FILTER_KEYS =
  %i[status year company_name company_group country value updated updater verification
     calculated source project outliers bookmark].freeze

include_set Abstract::FilterFormgroups
include_set Abstract::BookmarkFiltering
include_set Abstract::MetricChild, generation: 1
include_set Abstract::CachedCount
include_set Abstract::AnswerSearch
include_set Abstract::FixedAnswerSearch

# recount number of answers for a given metric when a Metric Value card is
# created or deleted
recount_trigger :type, :metric_answer, on: [:create, :delete] do |changed_card|
  changed_card.metric_card.fetch :metric_answer
end
# TODO: trigger recount from virtual answer batches

def fixed_field
  :metric_id
end

def partner
  :company
end

def bookmark_type
  :wikirate_company
end

def metric_card
  @metric_card ||= left&.metric_card
end

format do
  def secondary_sort_hash
    super.merge year: { value: :desc }
  end

  def filter_keys
    STANDARD_FILTER_KEYS + special_filter_keys
  end

  def special_filter_keys
    metric_card.relationship? ? [:related_company_group] : []
  end

  def default_filter_hash
    { company_name: "" }
  end
end

format :html do
  delegate :metric_card, to: :card

  def show_metric_count?
    false
  end

  def quick_filter_list
    @quick_filter_list ||=
      Card.fetch(:wikirate_company, :browse_company_filter).format.quick_filter_list
  end

  view :filter_value_formgroup do
    filter_value_formgroup metric_card.simple_value_type_code
  end

  def filter_value_formgroup metric_type, default=nil
    send "#{value_filter_type metric_type}_filter", :value, default
  end

  view :filter_related_company_group_formgroup, cache: :never do
    filter_related_company_group_formgroup
  end

  def filter_related_company_group_formgroup default=nil
    select_filter :related_company_group, default&.name
  end

  def related_company_group_options
    type_options :company_group
  end

  def value_filter_type value_type
    case value_type
    when :category, :multi_category
      :multiselect
    when :number, :money
      :range
    else
      :text
    end
  end

  def value_options
    metric_card.value_options_card&.options_hash&.reverse_merge "Unknown" => "Unknown"
  end

  def cell_views
    [:company_thumbnail_with_bookmark, :concise]
  end

  def header_cells
    [company_sort_links, answer_sort_links]
  end

  def details_view
    :company_details_sidebar
  end
end
