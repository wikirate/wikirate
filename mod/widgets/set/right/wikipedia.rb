INVALID_TITLE_CHARACTERS = %w[# < > [ ] | { }]
INVALID_TITLE_CHARACTERS_REGEXP =
  Regexp.new("[#{Regexp.escape INVALID_TITLE_CHARACTERS.join}]")

QUERY_ARGS = { format: :json, action: :query, redirects: 1 }.freeze

def wikipedia_response query={}
  JSON.parse URI::HTTPS.build(host: "en.wikipedia.org",
                              path: "/w/api.php",
                              query: wikipedia_json_query(query)).read
end

def wikipedia_json_query query
  query.reverse_merge! QUERY_ARGS
  query[:titles] ||= content
  query.to_query
end

# using the index.php urls means we don't have to normalize the titles
# (which I wish the api would do for us, but sigh..)
def wikipedia_url
  "https://en.wikipedia.org/w/index.php?#{{ title: content }.to_query}"
end

def wikipedia_extract
  response = wikipedia_response exsentences: 5, prop: :extracts,
                                exintro: nil, explaintext: nil
  return "" unless (pages = wikipedia_pages_data response)

  pages.to_a.first[1]["extract"]
rescue StandardError => _e
  ""
end

def wikipedia_pages_data response
  response.dig "query", "pages"
end

def invalid_title_characters?
  return unless content.match? INVALID_TITLE_CHARACTERS_REGEXP
  errors.add :content, "Characters not allowed: #{INVALID_TITLE_CHARACTERS.join ', '}"
end

event :validate_and_normalize_wikipedia_title, :validate, changed: :content, on: :save do
  if content.present?
    validate_title_from_content
  elsif new?
    validate_title_from_name
  else
    errors.add :content, "cannot be blank"
  end
end

def validate_title_from_content
  return if invalid_title_characters?
  extract_title_from_url
  title = valid_wikipedia_title content
  errors.add :content, "invalid Wikipedia Title" unless title.present?
end

def validate_title_from_name
  valid_wikipedia_title name.left
end

def valid_wikipedia_title title
  response = wikipedia_response titles: title, prop: :info
  pages = wikipedia_pages_data(response)
  return unless pages&.keys&.first != "-1"

  normed = normalize_title response
  self.content = normed || title
end

def normalize_title response
  return unless query = response["query"]
  normalize_title_via(query, "redirects") || normalize_title_via(query, "normalized")
end

def normalize_title_via query, term
  query.dig(term)&.first&.dig("to")
end

def extract_title_from_url
  return unless content.match?(/^http.*wikipedia/)
  self.content = URI.parse(content)&.path&.gsub "/wiki/", ""
rescue StandardError
  errors.add :content, "invalid URI"
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
