include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Abstract::BookmarkFiltering
include_set Abstract::JsonldSupported

def item_type_id
  TopicID
end

def bookmark_type
  :topic
end

format do
  def filter_cql_class
    TopicFilterCql
  end

  def default_sort_option
    "metric"
  end

  def filter_map
    %i[name topic_framework bookmark]
  end

  def default_filter_hash
    { name: "" }
  end

  def sort_options
    { "Most Metrics": :metric, "Most #{rate_subjects}": :company }.merge super
  end
end

format :html do
  def quick_filter_list
    Card::Set::Self::Topic.family_list.item_cards.map do |topic|
      topic_key = topic.right&.codename
      {
        topic_family: topic.name.right,
        icon: icon_tag(topic_key),
        class: "quick-filter-topic-#{topic_key}"
      }
    end
  end

  def filter_topic_framework_type
    :check
  end

  def filter_topic_framework_options
    type_options :topic_framework
  end

  def filter_topic_family_type
    :check
  end

  def filter_topic_family_options
    Card::Set::Self::Topic.family_list.item_names
  end
end

# FilterCql class for topic filtering
class TopicFilterCql < DeckorateFilterCql
  def topic_framework_cql framework
    val = framework.is_a?(Array) ? framework.clone.unshift(:in) : framework
    add_to_cql :left, val
  end

  def topic_family_cql family
    add_to_cql :right_plus, refer_to(:topic_family, family)
  end

  def name_cql title
    add_to_cql :right, name: [:match, title]
  end

  # def metric_cql metric
  #   add_to_cql :referred_to_by, left: { name: metric }, right: "topic"
  # end
  #
  # def dataset_cql dataset
  #   add_to_cql :referred_to_by, left: { name: dataset }, right: "topic"
  # end
  #
  # def company_cql company
  #   add_to_cql :found_by, "#{company}+topic"
  # end
end
