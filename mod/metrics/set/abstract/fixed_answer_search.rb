
def table_type
  partner
end

format do
  def record?
    filter_hash[:"#{partner}_name"]&.match?(/^\=/)
  end

  def query paging={}
    filter = filter_hash.merge fixed_field => left.id
    AnswerQuery.new filter, sort_hash, paging
  end
end
