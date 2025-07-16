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
    @family_list ||= featured_framework&.card&.category_card
  end

  def family_names
    @family_names ||= family_list.item_names.map do |title|
      [featured_framework, title].cardname
    end
  end

  def family_cards
    @family_cards ||= family_names.map(&:card)
  end

  def family_ids
    @family_id ||= family_names.map(&:card_id)
  end
end

delegate :featured_framework, :family_cards, :family_list, :family_ids,
         to: Self::Topic

def cql_content
  # exclude top-level topics
  { type: :topic, id: ["not in"] + family_ids }
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
