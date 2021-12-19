# Answer search for a given Metric

include_set Abstract::FilterFormgroups
include_set Abstract::BookmarkFiltering
include_set Abstract::MetricChild, generation: 1
include_set Abstract::CachedCount
include_set Abstract::AnswerSearch
include_set Abstract::FixedAnswerSearch

# recount number of answers for a given metric when an Answer card is
# created or deleted
recount_trigger :type, :metric_answer, on: %i[create delete] do |changed_card|
  changed_card.metric_card.fetch :metric_answer
end

# ...or when answer is (un)published
recount_trigger :type_plus_right, :metric_answer, :unpublished do |changed_card|
  field_recount changed_card do
    changed_card.left.metric_card.fetch :metric_answer
  end
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
  delegate :metric_card, to: :card

  STANDARD_FILTER_KEYS = %i[
    status year company_name company_group company_category country value updated updater
    verification calculated source dataset outliers bookmark
  ].freeze

  def secondary_sort_hash
    super.merge year: { value: :desc }
  end

  def standard_filter_keys
    STANDARD_FILTER_KEYS
  end

  def special_filter_keys
    keys = []
    keys << :related_company_group if metric_card.relationship?
    keys << :published if metric_card.steward?
    keys
  end

  def default_filter_hash
    { company_name: "" }
  end
end

format :html do
  view :export_links, cache: :never do
    if metric_card.relationship?
      wrap_with :div, class: "export-links py-2" do
        [wrap_export_links("Answer", export_format_links),
         wrap_export_links("Relationship", relationship_export_links)]
      end
    else
      super()
    end
  end

  def relationship_export_links
    metric_card.relationship_answer_card.format(:html).export_format_links
  end

  def wrap_export_links label, links
    wrap_with :div, class: "#{label.downcase}-export-links py-1" do
      "#{label} Export: #{links}"
    end
  end

  def show_metric_count?
    false
  end

  def quick_filter_list
    @quick_filter_list ||= :wikirate_company.card.format.quick_filter_list
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
