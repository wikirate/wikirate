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

event :update_oc_mapping_due_to_wikipedia_entry, :integrate, on: :save, when: :needs_oc_mapping? do
  oc = ::OpenCorporates::MappingAPI.fetch_oc_company_number wikipedia_url: content
  return unless oc.company_number.present?

  add_subcard cardname.left_name.field(:open_corporates),
              content: oc.company_number, type: :phrase
  add_subcard cardname.left_name.field(:incorporation),
              content: jurisdiction_name(oc.jurisdiction_code_of_incorporation),
              type: :pointer
  add_subcard cardname.left_name.field(:headquarters),
              content: jurisdiction_name(oc.jurisdiction_code),
              type: :pointer
end

# TODO: reduce duplicated code
def jurisdiction_name oc_code
  oc_code = "oc_#{oc_code}" unless oc_code.to_s =~ /^oc_/
  Card.fetch_name oc_code.to_sym
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

def needs_oc_mapping?
  (l = left) && l.open_corporates.blank?
end
