require "link_thumbnailer"

format :html do
  view :input, cache: :never do
    form.text_field :content, class: "d0-card-content form-control",
                              placeholder: "http://example.com"
  end
end

event :validate_content, :validate, on: :save do
  URI.parse Addressable::URI.encode(content)
rescue URI::Error => e
  errors.add :link, "invalid URI: #{content}, #{e.message}"
end

FIELD_CODENAME = { title: :wikirate_title, description: :description }.freeze

event :add_source_file, :integrate_with_delay, on: :create, when: :no_file? do
  Card.create name: name.left_name.field(:file), type: :file, remote_file_url: content
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
  left.field :wikirate_website, content: host, type: :pointer
  return if Card.exist?(host) || host.blank?
  left.subcard host, type: :wikirate_website
end

def no_file?
  left.fetch(:file).blank?
end

def parsed_uri
  Addressable::URI.parse content
end

def host
  @host ||= parsed_uri&.host
end

def duplicates
  @duplicates ||= Card::Source.search_by_url content
end

def link_present?
  content.present?
end

def wikirate_link?
  content.match(%r{^https?\:\/\/(www\.)?wikirate\.org})
end
