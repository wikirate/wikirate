include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Abstract::TopicSearch
include_set Abstract::FluidLayout

def esg_codenames
  %i[environment social governance]
end

def cql_content
  { type: :topic, id: esg_codenames.map(&:card_id).unshift("not in") }
end

format do
  def default_filter_hash
    { topic_framework: :esg_topics.cardname }
  end
end

format :html do
  view :page, template: :haml
end
