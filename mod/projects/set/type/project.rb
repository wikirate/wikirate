include_set Abstract::Thumbnail

card_reader :wikirate_company
card_reader :metric
card_reader :organizer
card_reader :year

def answers
  @answers ||= Answer.where where_answer
end

def answers_since_start
  Answer.where(where_answer).where "updated_at > ?", created_at
end

def where_answer
  where_year { where_record }
end

def where_record
  { metric_id: metric_ids, company_id: company_ids }
end

def company_ids
  @company_ids ||= wikirate_company_card.valid_company_cards.map(&:id)
end

def metric_ids
  @metric_ids ||= metric_card.valid_metric_cards.map(&:id)
end

def metrics
  metric_card.valid_metric_cards.map(&:name)
end

def years
  return @years if !@years.nil?
  valids = year_card.valid_year_cards.map(&:name)
  @years = valids.empty? ? false : valids
end
