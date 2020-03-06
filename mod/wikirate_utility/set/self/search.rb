def wql_content
  { type:
      %i[in wikirate_company wikirate_topic metric metric_title project research_group],
    fulltext_match: "$keyword",
    sort: "relevance" }
end

format :html do
  # HACK. This makes it so that the main search results don't include metric title
  # cards.  But those cards are needed in the navbar (json) views
  def search_with_rescue query_args
    query_args ||= {}
    query_args[:and] = { type_id: ["ne", MetricTitleID] }
    super query_args
  end
end
