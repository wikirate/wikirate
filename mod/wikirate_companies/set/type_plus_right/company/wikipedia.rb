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
  def excerpt_uri
    card.excerpt_uri exsentences: 5, prop: :extracts, exintro: nil, explaintext: nil
  end

  view :core, async: false, wrap: :slot do
    render_standard_core
  end

  def excerpt_body
    content_tag :div,
                class: "_wikipediaExcerpt _unloaded",
                data: { url: excerpt_uri.to_s } do
      ""
    end
  end
end
