include_set Abstract::BrowseFilterForm
include_set Abstract::BookmarkFiltering

SDG_TOPIC_IDS =
  [1094740, 1094743, 1094744, 1094771, 1094774, 1094777, 1094780, 1094784, 1094787,
   1099746, 1099750, 1099750, 1104669, 1104672, 1104675, 1104678, 1104681].freeze

def default_filter_hash
  { name: "" }
end

def default_sort_option
  :bookmarkers
end

def filter_keys
  %i[name wikirate_topic designer project metric_type research_policy year bookmark]
end

def target_type_id
  MetricID
end

def filter_class
  MetricFilterQuery
end

def bookmark_type
  :metric
end

format :html do
  def filter_label key
    key == :metric_type ? "Metric type" : super
  end

  def quick_filter_list
    bookmark_quick_filter + topic_quick_filters + project_quick_filters
  end

  def default_year_option
    { "Any Year" => "" }
  end

  def sort_options
    { "Most Companies": :company,
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

  def custom_quick_filters
    haml :sdg_quick_filters, topic_ids: SDG_TOPIC_IDS
  end

  def sdg_help_text
    'The Sustainable Development Goals (SDGs) are a group of 17 global goals <br/>' \
    'conceived as a "blueprint to achieve a better and more sustainable future".'
  end
end
