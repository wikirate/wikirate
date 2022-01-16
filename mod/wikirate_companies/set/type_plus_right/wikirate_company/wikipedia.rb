include_set Abstract::CompanyExcerpt

QUERY_ARGS = { format: :json, action: :query, redirects: 1 }.freeze

def excerpt_host
  "en.wikipedia.org"
end

def excerpt_path
  "/w/api.php"
end

def excerpt_query query
  query[:titles] ||= content
  QUERY_ARGS.merge(query).to_query
end

# using the index.php urls means we don't have to normalize the titles
# (which I wish the api would do for us, but sigh..)
def excerpt_link_url
  "https://en.wikipedia.org/w/index.php?#{{ title: content }.to_query}"
end

format :html do
  def excerpt_body
    return "" unless (pages = page_data)

    pages.to_a.first[1]["extract"]
  end

  private

  def page_json
    excerpt_json exsentences: 5, prop: :extracts, exintro: nil, explaintext: nil
  end

  def page_data
    page_json&.dig "query", "pages"
  end
end
