# including module must respond to
# `fixed_field`, returning a Symbol representing an AnswerQuery id filter, and
# `partner`, returning a Symbol

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
  delegate :partner, to: :card

  def record?
    filter_hash[:"#{partner}_name"]&.match?(/^\=/)
  end

  def filter_query_hash
    super.merge card.fixed_filter
  end
end
