def unknown?
  false
end

QUERY_ARGS = { format: :json, action: :query, prop: :extracts, redirects: 1,
               exintro: nil, explaintext: nil }.freeze

def wikipedia_query_uri args={}
  query = args.extract!(:sentences, :chars).transform_keys { |k| "ex#{k}".to_sym }
              .merge(QUERY_ARGS)
  query[:titles] = wikipedia_title
  URI::HTTPS.build host: "en.wikipedia.org", path: "/w/api.php", query: query.to_query
end

def wikipedia_title
  db_content.present? ? db_content : left.name
end

def wikipedia_url
  "https://en.wikipedia.org/wiki/#{wikipedia_title}"
end

def wikipedia_extract
  response = JSON.parse wikipedia_query_uri(sentences: 5).read
  return "" unless response["query"] && response["query"]["pages"]
  first_page = response["query"]["pages"].to_a.first
  first_page[1]["extract"]
rescue Exception => _e
  ""
end

format :html do
  delegate :wikipedia_extract, :wikipedia_url, to: :card
  view :edit do
    Card.exists?(card.name) ? super() : _render_new
  end

  def unknown_disqualifies_view? _view
    false
  end

  def show_menu_item_edit?
    true
  end

  view :core, async: true do
    extract = wikipedia_extract
    extract += wrap_with(:p, original_link) if extract.present?
    extract
  end

  def original_link
    super wikipedia_url, class: "external-link", text: "<small>Visit Original</small>"
  end
end
