
def table_type
  partner
end

def fixed_filter
  { fixed_field => left.id }
end

def query paging={}
  AnswerQuery.new fixed_filter, {}, paging
end

format do
  def record?
    filter_hash[:"#{partner}_name"]&.match?(/^\=/)
  end

  def query paging={}
    filter = filter_hash.merge card.fixed_filter
    AnswerQuery.new filter, sort_hash, paging
  end
end
