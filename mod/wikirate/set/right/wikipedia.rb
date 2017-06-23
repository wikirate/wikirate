def unknown?
  false
end

def wikipedia_query_uri args={}
  uri = "https://en.wikipedia.org/w/api.php?format=json&action=query&"\
            "prop=extracts&exintro=&explaintext=&" \
            "&redirects=1&titles=#{wikipedia_title}"
  uri += extract_api_options args
  URI.parse uri
end

def wikipedia_url
  "https://en.wikipedia.org/wiki/#{wikipedia_title}"
end

def wikipedia_title
  db_content.present? ? db_content : left.name
end

def extract_api_options args
  [:sentences, :chars].map do |key|
    "&ex#{key}=#{args[key]}" if args[key]
  end.compact.join
end

def wikipedia_extract
  response = JSON.parse wikipedia_query_uri(sentences: 5).read
  return unless response["query"] && response["query"]["pages"]
  first_page = response["query"]["pages"].to_a.first
  first_page[1]["extract"]
rescue Exception => _e
  ""
end

format :html do
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
    card.wikipedia_extract + original_link(wikipedia_url)
  end
end
