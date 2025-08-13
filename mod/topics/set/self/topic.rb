include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Abstract::TopicSearch
include_set Abstract::FluidLayout
include_set Abstract::ExportAll

class << self
  def featured_framework
    :esg_topics

    # once a gem we can replace with the following
    # Cardio.config.featured_topic_framework
  end

  def family_list
    featured_framework&.card&.category_card
  end
end

delegate :featured_framework, :family_list, to: Self::Topic

def cql_content
  { type: :topic }.tap do |cql|
    # exclude top-level topics
    excluded_ids = family_list.item_ids
    cql[:id] = ["not in"] + excluded_ids if excluded_ids.present?
  end
end

format do
  def default_filter_hash
    { topic_framework: card.featured_framework.cardname }
  end
end

format :html do
  view :page, template: :haml

  view :topic_tree, cache: :deep, template: :haml
end
