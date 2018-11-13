require "timeout"

event :normalize_link, :prepare_to_validate, on: :save do
  self.content = content&.strip
end

event :validate_link, :validate, on: :save, when: :link_present? do
  return if content.start_with? "http://", "https://"
  errors.add :url, "must begin with http:// or https://"
end

event :populate_website, :prepare_to_store, on: :create, when: :link_present? do
  host = URI.parse(content).host
  left.add_subfield :wikirate_website, content: host, type_id: PointerID
  return if Card.exists?(host) || host.blank?
  add_subcard host, type_id: Card::WikirateWebsiteID
end

event :populate_title_and_description, :prepare_to_store,
      on: :create, when: :thumbnail_needed? do
  return unless (thumbnail = generate_thumbnail)
  handle_field :title, thumbnail
  handle_field :description, thumbnail
end

def thumbnail_needed?
  !(subfield(:title) && subfield(:description))
end

def link_present?
  content.present?
end

def generate_thumbnail
  Timeout::timeout(3) do
    LinkThumbnailer.generate content
  end
rescue LinkThumbnailer::Exceptions, Net::HTTPExceptions, Timeout::Errors
  Rails.logger.info "failed to extract information from #{url}"
end

def handle_field field, thumbnail
  return if subfield field
  value = clean_text thumbnail.send(field)
  add_subfield field, content: value if value.present?
end

# temporary fix
def clean_text text
  return if text.blank?
  # remove all 4-byte unicode characters
  regex = /[\u{10000}-\u{fffff}]/
  text.gsub! regex, ""
end
