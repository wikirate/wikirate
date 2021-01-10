include_set Abstract::Table
include_set Abstract::BrowseFilterForm

def item_type
  "Answer" # :metric_answer.cardname
end

# shared search method for card and format
def search args={}
  return_type = args.delete :return
  query = args.delete(:query) || query(args)
  run_query_returning query, return_type
end

def run_query_returning query, return_type
  case return_type
  when :name  then query.run.map(&:name)
  when :count then query.count
  else             query.run
  end
end

def query paging={}
  AnswerQuery.new({}, {}, paging)
end

format do
  def filter_hash_from_params
    super.tap do |h|
      normalize_filter_hash h if h
    end
  end

  def search_with_params
    @search_with_params ||= card.search query: query
  end

  def count_with_params
    @count_with_params ||= card.search query: count_query, return: :count
  end

  def query
    AnswerQuery.new query_hash, sort_hash, paging_params
  end

  def count_query
    AnswerQuery.new query_hash
  end

  # note: overridden in fixed
  def query_hash
    filter_hash || {}
  end

  def card_content_limit
    nil
  end

  def normalize_filter_hash hash
    %i[metric company].each do |type|
      next unless (id = hash.delete :"#{type}_id")&.present?
      hash[:"#{type}_name"] = "=#{id.to_i.cardname}"
    end
  end

  def default_limit
    Auth.signed_in? ? 5000 : 500
  end
end

format :csv do
  view :core do
    Answer.csv_title + query.answer_lookup.map(&:csv_line).join
  end
end
