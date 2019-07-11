def virtual?
  new?
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
  @wikipedia_extract ||= extract_wikipedia_content
end

def extract_wikipedia_content
  response = JSON.parse wikipedia_query_uri(sentences: 5).read
  return "" unless response["query"] && response["query"]["pages"]
  first_page = response["query"]["pages"].to_a.first
  first_page[1]["extract"]
rescue Exception => _e
  ""
end

event :update_oc_mapping_due_to_wikipedia_entry, :integrate,
      on: :save, when: :needs_oc_mapping? do

  oc = ::OpenCorporates::MappingAPI.fetch_oc_company_number wikipedia_url: content
  return unless oc.company_number.present?

  add_left_subcard :open_corporates, oc.company_number, :phrase
  add_left_subcard :incorporation, jurisdiction_name(oc.incorporation_jurisdiction_code)
  add_left_subcard :headquarters, jurisdiction_name(oc.jurisdiction_code)
end

def add_left_subcard fieldname, content, type=:pointer
  add_subcard name.left_name.field(fieldname), content: content, type: type
end

def needs_oc_mapping?
  (l = left) && l.open_corporates.blank?
end

# TODO: reduce duplicated code
def jurisdiction_name oc_code
  oc_code = "oc_#{oc_code}" unless oc_code.to_s.match?(/^oc_/)
  Card.fetch_name oc_code.to_sym
end

format :html do
  delegate :wikipedia_extract, :wikipedia_url, to: :card

  view :core, async: true do
    extract = wikipedia_extract
    extract += wrap_with(:p, original_link, class: "origin-link") if extract.present?
    extract
  end

  def original_link
    super wikipedia_url, class: "external-link", text: "<small>en.wikipedia.org</small>"
  end
end

format :json do
  view :core do
    card.content.empty? ? nil : card.content
  end
end
