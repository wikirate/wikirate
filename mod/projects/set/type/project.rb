include_set Abstract::TwoColumnLayout
include_set Abstract::Thumbnail
include_set Abstract::Tabs
include_set Abstract::Export

card_reader :wikirate_company
card_reader :metric
card_reader :organizer

def answers
  @answers ||= Answer.where(where_answer).where("updated_at > ?", created_at)
end

def where_answer
  { metric_id: metric_ids, company_id: company_ids }
end

def metric_ids
  @metric_ids ||= metrics.map do |metric|
    Card.fetch_id metric
  end.compact
end

def metrics
  metric_card.item_names
end

def company_ids
  @company_ids ||= wikirate_company_card.item_names.map do |company|
    Card.fetch_id company
  end.compact
end






