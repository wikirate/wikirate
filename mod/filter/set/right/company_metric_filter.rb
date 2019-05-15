include_set Abstract::RightFilterForm
include_set Abstract::FilterFormgroups

def filter_keys
  %i[year status]
end

def advanced_filter_keys
  %i[check metric wikirate_topic metric_type value updated project research_policy]
end

def default_sort_option
  :importance
end

def default_filter_option
  { year: :latest, status: :exists }
end

format :html do
  def filter_label field
    field.to_sym == :metric_type ? "Metric type" : super
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
