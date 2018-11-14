require "timeout"

FIELD_CODENAME = { title: :wikirate_title, description: :description }.freeze

event :normalize_link, :prepare_to_validate, on: :save do
  self.content = content&.strip
end

event :validate_link, :validate, on: :save, when: :link_present? do
  if !content.start_with? "http://", "https://"
    errors.add :url, "must begin with http:// or https://"
  elsif wikirate_link?
    errors.add :invalid, "Cannot use wikirate url as source"
  elsif duplicates.any?
    errors.add :duplicate, "duplicate of #{duplicates.first.name}"
  end
end

event :populate_website, :prepare_to_store, on: :create, when: :link_present? do
  host = URI.parse(content).host
  left.add_subfield :wikirate_website, content: host, type_id: PointerID
  return if Card.exists?(host) || host.blank?
  left.add_subcard host, type_id: Card::WikirateWebsiteID
end

event :populate_title_and_description, :prepare_to_store,
      on: :create, when: :populate_from_thumbnail? do
  return unless (thumbnail = generate_thumbnail)
  handle_field :title, thumbnail
  handle_field :description, thumbnail
end

def duplicates
  @duplicates ||= Self::Source.find_duplicates content
end

def populate_from_thumbnail?
  return if (subfield(:wikirate_title) && subfield(:description))
  left&.subfield(:file)&.html_file?
end

def link_present?
  content.present?
end

def wikirate_link?
  content.match(/^http\s?\:\/\/(www\.)?wikirate\.org/)
end

def generate_thumbnail
  Timeout::timeout(5) do
    LinkThumbnailer.generate content
  end
rescue LinkThumbnailer::Exceptions, Net::HTTPExceptions, Timeout::Error
  Rails.logger.info "failed to extract information from #{content}"
  nil
end

def handle_field field, thumbnail
  fieldcode = FIELD_CODENAME[field]
  return if subfield fieldcode
  value = clean_text thumbnail.send(field)
  left.add_subfield fieldcode, content: value if value.present?
end

# temporary fix
def clean_text text
  return if text.blank?
  # remove all 4-byte unicode characters
  regex = /[\u{10000}-\u{fffff}]/
  text.gsub regex, ""
end
