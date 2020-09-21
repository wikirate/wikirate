include_set Set::Self::Search

format :html do
  def keyword_search_title keyword
    cql_search? ? super : nil
  end
end
