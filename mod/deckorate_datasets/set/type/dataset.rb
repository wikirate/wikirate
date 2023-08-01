include_set Abstract::Thumbnail
include_set Abstract::DeckorateTabbed
include_set Abstract::Bookmarkable
include_set Abstract::Attributable

card_reader :wikirate_company, type: :list
card_reader :metric, type: :list
card_reader :year, type: :list
card_reader :parent, type: :pointer
card_reader :data_subset, type: :search_type
card_reader :wikirate_topic, type: :list

def parent_dataset_card
  Card[parent_dataset]
end

def parent_dataset
  parent_card.first_name
end

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
  @company_ids ||= wikirate_company_card.item_ids
end

def metric_ids
  @metric_ids ||= metric_card.item_ids
end

def year_ids
  @year_ids ||= year_card.item_ids
end

def metrics
  @metrics ||= metric_card.item_names
end

def companies
  @companies ||= wikirate_company_card.item_names
end

def years
  @years ||= year_card.item_names
end

def years?
  years.present?
end

# used in filtering answers on company and dataset pages
# @param status [Symbol] researched, known, not_researched
def filter_path_args status
  { filter: { dataset: name, status: status } }
end
