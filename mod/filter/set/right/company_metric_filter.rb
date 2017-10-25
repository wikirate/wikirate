include_set Abstract::MetricRecordFilter

def filter_keys
  %w[metric_value year]
end

def advanced_filter_keys
  %w[metric wikirate_topic project research_policy importance metric_type]
end

def default_sort_option
  :importance
end

format :html do
  view :core, cache: :never do
    filter_fields true
  end

  def filter_label field
    field.to_sym == :metric ? "Keyword" : super
  end

  def filter_body_header
    "Metric"
  end

  def advanced_filter_form
    output [
      advanced_filter_formgroups,
      "<hr/>",
      _render_sort_formgroup
    ]
  end

  def filter_fields categories
    return "".html_safe unless categories.present?
    categories = card.filter_keys + card.advanced_filter_keys
    cats = categories.each_with_object({}) do |cat, h|
      h[cat] = { label: filter_label(cat),
                 input_field: _render("#{cat}_formgroup"),
                 active: filter_active?(cat) }
    end
    filter_form cats, action: path(mark: card.name.left, view: content_view),
                      class: "filter-container slotter sub-content",
                      id: "_filter_container"
  end


  def sort_options
    {
      "Importance to Community (net votes)" => :importance,
      "Metric Designer (Alphabetical)" => :metric_name,
      "Metric Title (Alphabetical)" => :title_name,
      "Recently Updated" => :updated_at
    }
  end
end
