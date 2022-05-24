include_set Set::Self::Search

format :html do
  def keyword_search_title
    cql_keyword? ? super : nil
  end
end
