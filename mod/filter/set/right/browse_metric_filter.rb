include_set Abstract::BrowseFilterForm

def default_sort_option
  "upvoted"
end

def filter_keys
  %i[name wikirate_topic wikirate_company]
end

def advanced_filter_keys
  %i[designer project metric_type research_policy year]
end

def target_type_id
  MetricID
end

def filter_class
  MetricFilterQuery
end

def sort_wql
  wql = super
  wql[:sort] =
    case current_sort
    when "values"
      { right: "value", right_plus: "*cached count" }
    when "recent"
      wql.delete :sort_as
      "update"
    when "company"
      { right: "company", right_plus: "*cached count" }
    else
      # upvoted as default
      { right: "*vote count" }
    end
  wql
end

format :html do
  def filter_label key
    key == :metric_type ? "Metric type" : super
  end

  def default_year_option
    { "Any Year" => "" }
  end

  def sort_options
    {
      "Highest Voted" => "upvoted",
      "Most Recent" => "recent",
      # "Most Companies" => "wikirate_company" # "company"
    }
  end

  view :metric_type_formgroup, cache: :never do
    metric_type_select
  end

  view :research_policy_formgroup, cache: :never do
    research_policy_select
  end

  view :wikirate_topic_formgroup, cache: :never do
    "woot"
  end

  def type_options type_codename, order="asc"
    if type_codename == :wikirate_topic
      Card.search referred_to_by: {
        left: { type_id: Card::MetricID },
        right: "topic"
      }, type_id: Card::WikirateTopicID,
                  return: :name, sort: "name", dir: order
    else
      super type_codename, order
    end
  end
end
