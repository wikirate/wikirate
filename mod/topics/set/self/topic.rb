include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Abstract::TopicSearch
include_set Abstract::FluidLayout

def featured_list
  %i[esg_topics category].card
end

def cql_content
  { type: :topic, id: ["not in"] + featured_list.item_ids }
end

format do
  def default_filter_hash
    { topic_framework: :esg_topics.cardname }
  end
end

format :html do
  view :page, template: :haml
end
