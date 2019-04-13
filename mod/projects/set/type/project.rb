include_set Abstract::Thumbnail

card_reader :wikirate_company
card_reader :metric
card_reader :organizer
card_reader :year
card_reader :parent
card_reader :subproject

def parent_project_card
  Card[parent_project]
end

def parent_project
  parent_card.item_names.first
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
  @company_ids ||= wikirate_company_card.valid_item_ids
end

def metric_ids
  @metric_ids ||= metric_card.valid_item_ids
end

def year_ids
  @year_ids ||= years && year_card.valid_item_ids
end

def metrics
  metric_card.valid_item_names
end

def companies
  wikirate_company_card.valid_item_names
end

def years
  return @years unless @years.nil?
  valids = year_card.valid_item_names
  @years = valids.empty? ? false : valids
end

alias_method :metric_list, :metrics
alias_method :company_list, :companies
alias_method :year_list, :years

# used in filtering answers on company and project pages
# @param values [Symbol] researched, known, not_researched
# (need better term for this param)
def filter_path_args values
  filter = { project: name, metric_value: values  }
  # show latest project year.  could consider updating answer tables
  # to handle latest value among a group of years, but that's not yet
  # an option
  filter[:year] = years.first if years && years.one?
  { filter: filter }
end
