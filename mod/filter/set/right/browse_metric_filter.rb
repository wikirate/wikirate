include_set Abstract::BrowseFilterForm

def default_filter_option
  { name: "" }
end

def default_sort_option
  :upvoted
end

def filter_keys
  %i[name wikirate_topic designer project metric_type research_policy year]
end

def target_type_id
  MetricID
end

def filter_class
  MetricFilterQuery
end

def sort_wql
  if current_sort.to_sym == :upvoted
    { sort: { right: "*vote count" }, dir: "desc" }
  else
    super
  end
end

format :html do
  def filter_label key
    key == :metric_type ? "Metric type" : super
  end

  def default_year_option
    { "Any Year" => "" }
  end

  def sort_options
    { "Highest Voted": :upvoted,
      "Most Companies": :company,
      "Most Answers": :answer }.merge super
  end

  def type_options type_codename, order="asc", max_length=nil
    if type_codename == :wikirate_topic
      wikirate_topic_type_options order
    else
      super
    end
  end

  def wikirate_topic_type_options order
    Card.search referred_to_by: { left: { type_id: Card::MetricID },
                                  right: "topic" },
                type_id: Card::WikirateTopicID,
                return: :name,
                sort: "name",
                dir: order
  end
end
