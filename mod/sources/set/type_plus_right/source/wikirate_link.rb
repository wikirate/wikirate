FIELD_CODENAME = { title: :wikirate_title, description: :description }.freeze

event :add_source_file, :initialize, on: :create, when: :no_file? do
  left.add_subfield :file, type: Card::FileID, remote_file_url: content
end

event :normalize_link, :prepare_to_validate, on: :save do
  self.content = content&.strip
end

event :validate_link, :validate, on: :save, when: :link_present? do
  if !content.start_with? "http://", "https://"
    errors.add :url, "must begin with http:// or https://"
  elsif wikirate_link?
    errors.add :invalid, "Cannot use wikirate url as source"
  end
end

event :populate_website, :prepare_to_store, on: :create, when: :link_present? do
  host = URI.parse(content).host
  left.add_subfield :wikirate_website, content: host, type_id: PointerID
  return if Card.exists?(host) || host.blank?
  left.add_subcard host, type_id: Card::WikirateWebsiteID
end

def no_file?
  !left.subcards[:file.cardname]
end

def duplicates
  @duplicates ||= Self::Source.find_duplicates content
end

def link_present?
  content.present?
end

def wikirate_link?
  content.match(%r{^http\s?\://(www\.)?wikirate\.org})
end
