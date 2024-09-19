INVALID_TITLE_CHARACTERS = %w[# < > [ ] | { }].freeze
INVALID_TITLE_CHARACTERS_REGEXP =
  Regexp.new("[#{Regexp.escape INVALID_TITLE_CHARACTERS.join}]")

event :validate_and_normalize_wikipedia_title, :validate, changed: :content, on: :save do
  if content.present?
    validate_title_from_content
  elsif new?
    validate_new_and_blank
  else
    errors.add :content, "cannot be blank"
  end
end

event :update_oc_mapping_due_to_wikipedia_entry, :integrate,
      on: :save, when: :needs_oc_mapping? do

  oc = ::OpenCorporates::MappingApi.fetch_oc_company_number wikipedia_url: content
  return unless oc&.company_number&.present?

  add_left_subcard :open_corporates, oc.company_number, :phrase
  add_left_subcard :incorporation, region_for_code(oc.incorporation_jurisdiction_code)
  add_left_subcard :headquarters, region_for_code(oc.jurisdiction_code)
end

def region_for_code oc_code
  Card::Region.region_name_for_oc_code oc_code
end

def add_left_subcard fieldname, content, type=:pointer
  subcard name.left_name.field(fieldname), content: content, type: type
end

def needs_oc_mapping?
  false
  # skip until oc api is fixed

  # (l = left) && l.open_corporates.blank?
end

private

def validate_title_from_content
  return if invalid_title_characters?
  extract_title_from_url
  title = valid_wikipedia_title content
  errors.add :content, "invalid Wikipedia Title" unless title.present?
end

def invalid_title_characters?
  return unless content.match? INVALID_TITLE_CHARACTERS_REGEXP
  errors.add :content, "Characters not allowed: #{INVALID_TITLE_CHARACTERS.join ', '}"
end

def extract_title_from_url
  return unless content.match?(/^http.*wikipedia/)
  self.content = URI.parse(content)&.path&.gsub "/wiki/", ""
rescue StandardError
  errors.add :content, "invalid URI"
end

def valid_wikipedia_title title
  json = excerpt_json titles: title, prop: :info
  pages = wikipedia_page_data json
  return unless pages&.keys&.first != "-1"

  normed = normalize_title json
  self.content = normed || title
end

def wikipedia_page_data json
  json&.dig "query", "pages"
end

def normalize_title response
  return unless (query = response["query"])
  normalize_title_via(query, "redirects") || normalize_title_via(query, "normalized")
end

def normalize_title_via query, term
  query.dig(term)&.first&.dig("to")
end

# TODO: refactor away direct subcard manipulation or explain why it is necessary
def validate_new_and_blank
  valid_wikipedia_title name.left
  return if content.present?

  if supercard
    supercard.drop_subcard name
  else
    errors.add :content, "cannot be blank"
  end
end
