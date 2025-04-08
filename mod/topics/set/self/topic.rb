include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Abstract::TopicSearch
include_set Abstract::FluidLayout

class << self
  def featured_framework
    :esg_topics

    # one a gem we can replace with the following
    # Cardio.config.featured_topic_framework
  end

  def family_list
    @family_list ||= featured_framework&.card&.category_card
  end

  def family_names
    @family_names ||= family_list.item_names
  end
end

def featured_framework
  Self::Topic.featured_framework
end

def family_list
  Self::Topic.family_list
end

def cql_content
  { type: :topic, id: ["not in"] + family_list.item_ids }
end

format do
  def default_filter_hash
    { topic_framework: card.featured_framework.cardname }
  end
end

format :html do
  view :page, template: :haml
end
