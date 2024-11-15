# Answer search for a given Metric

include_set Abstract::BookmarkFiltering
include_set Abstract::MetricChild, generation: 1
include_set Abstract::CachedCount
include_set Abstract::FixedRecordSearch

# recount number of answers for a given metric when an Answer card is
# created or deleted
recount_trigger :type, :record, on: %i[create delete] do |changed_card|
  answer_fields changed_card.metric_card
end

# ...or when metric is (un)published
field_recount_trigger :type_plus_right, :metric, :unpublished do |changed_card|
  answer_fields changed_card.left
end

# ...or when answer is (un)published
field_recount_trigger :type_plus_right, :record, :unpublished do |changed_card|
  answer_fields changed_card.left.metric_card
end

recount_trigger :type_plus_right, :metric, :formula do |changed_card|
  answer_fields changed_card.left
end

def self.answer_fields metric
  ([metric] + metric.depender_metrics).map { |m| m.fetch :record }
end

# TODO: trigger recount from virtual record batches

def fixed_field
  :metric_id
end

def partner
  :company
end

def bookmark_type
  :company
end

def metric_card
  @metric_card ||= left
end

format do
  delegate :metric_card, to: :card

  def export_title
    "#{metric_card.metric_title.to_name.url_key}+Answer"
  end

  # def secondary_sort_hash
  #   super.merge year: { value: :desc }
  # end

  def filter_map
    filter_map_without_keys(super, :metric)
      .tap { |arr| arr << :related_company_group if metric_card.relation? }
  end

  def default_filter_hash
    { company_name: "" }
  end

  def simple_sort
    {
      company_name: 8,
      value: 2,
      year: 2
    }
  end

  def record_log_sort
    {
      company_name: 8,
      value: 2,
      year: 2
    }
  end

  def fixed_filter_field
    :metric
  end
end

format :html do
  view :export_links, cache: :never do
    if metric_card.relation?
      wrap_with :div, class: "export-links py-2" do
        [wrap_export_links("Answer", export_format_links),
         wrap_export_links("Relationship", relationship_export_links)]
      end
    else
      super()
    end
  end

  before :core do
    voo.items[:hide] = :metric_thumbnail
  end

  def show_metric_count?
    false
  end

  def quick_filter_list
    @quick_filter_list ||= :company.card.format.quick_filter_list
  end

  def filter_value_type
    case metric_card.simple_value_type_code
    when :category, :multi_category
      :check
    when :number, :money
      :range
    else
      :text
    end
  end

  def filter_related_company_group_type
    :radio
  end

  def filter_related_company_group_options
    type_options :company_group
  end

  def filter_value_options
    metric_card.value_options_card&.options_hash&.reverse_merge "Unknown" => "Unknown"
  end
end
