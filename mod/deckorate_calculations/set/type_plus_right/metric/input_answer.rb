# Answer search for a given Metric

include_set Abstract::BookmarkFiltering
include_set Abstract::MetricChild, generation: 1
include_set Abstract::CachedCount
include_set Abstract::FullAnswerSearch

def query_hash
  { depender_metric: metric_card.name }
end

def metric_card
  @metric_card ||= left
end

format do
  delegate :metric_card, to: :card

  def export_title
    "#{metric_card.metric_title.to_name.url_key}+Input Answer"
  end

  def secondary_sort_hash
    super.merge year: { value: :desc }
  end

  # def filter_map
  #   filter_map_without_keys(super, :metric)
  #     .tap { |arr| arr << :related_company_group if metric_card.relationship? }
  # end

  def default_filter_hash
    { company_name: "" }
  end

  def sort_options
    super.reject { |_k, v| v == :metric_title }
  end
end

format :html do
  # view :export_links, cache: :never do
  #   if metric_card.relationship?
  #     wrap_with :div, class: "export-links py-2" do
  #       [wrap_export_links("Answer", export_format_links),
  #        wrap_export_links("Relationship", relationship_export_links)]
  #     end
  #   else
  #     super()
  #   end
  # end

  # def show_metric_count?
  #   false
  # end

  # def quick_filter_list
  #   @quick_filter_list ||= :wikirate_company.card.format.quick_filter_list
  # end
  #
  # def filter_value_type
  #   case metric_card.simple_value_type_code
  #   when :category, :multi_category
  #     :check
  #   when :number, :money
  #     :range
  #   else
  #     :text
  #   end
  # end
  #
  # def filter_related_company_group_type
  #   :radio
  # end
  #
  # def filter_related_company_group_options
  #   type_options :company_group
  # end
  #
  # def filter_value_options
  #   metric_card.value_options_card&.options_hash&.reverse_merge "Unknown" => "Unknown"
  # end
end