include_set Self::Search

format :html do
  def keyword_search_title keyword
    wql_search? ? super : nil
  end
end
