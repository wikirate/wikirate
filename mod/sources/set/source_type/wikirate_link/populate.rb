event :autopopulate_website, :prepare_to_store, on: :create, when: :populate_website? do
  link = subfield(:wikirate_link).content
  host = URI.parse(link).host
  add_subfield :wikirate_website, content: "[[#{host}]]", type_id: PointerID
  return if Card.exists?(host) || host.blank?
  add_subcard host, type_id: Card::WikirateWebsiteID
end

def populate_website?
  !subfield(:wikirate_website).present? && subfield(:wikirate_link).present? &&
    errors.empty?
end

def populate_title_and_description
  return unless sourcebox?
  thumbnail = LinkThumbnailer.generate url

  add_title thumbnail
  add_description thumbnail
rescue LinkThumbnailer::Exceptions, Net::HTTPExceptions, URI::InvalidURIError
  Rails.logger.info "failed to extract information from #{url}"
end

def add_title thumbnail
  return if subfield(:wikirate_title) || thumbnail.title.empty?
  add_subfield :wikirate_title, content: thumbnail.title
end

def add_description thumbnail
  return if subfield :description
  description = clean_description thumbnail.description
  return unless description.present?
  add_subfield :description, content: description
end

# temporary fix
def clean_description text
  return if text.blank?
  # remove all 4-byte unicode characters
  regex = /[\u{10000}-\u{fffff}]/
  text.gsub! regex, ""
end
