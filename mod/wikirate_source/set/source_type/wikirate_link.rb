card_accessor :file, type: :file
card_accessor :wikirate_link, type: :phrase
card_accessor :wikirate_website, type: :pointer

format :html do
  view :original_link do
    original_link card.wikirate_link, text: voo.title
  end
end

event :autopopulate_website, :prepare_to_store, on: :create, when: :populate_website? do
  link = subfield(:wikirate_link).content
  host = URI.parse(link).host
  add_subfield :wikirate_website, content: "[[#{host}]]", type_id: PointerID
  return if Card.exists?(host) || host.blank?
  add_subcard host, type_id: Card::WikirateWebsiteID
end

event :import_linked_source, :integrate_with_delay, on: :save do
  generate_pdf if import? && html_link?
end

event :process_source_url, after: :check_source, on: :create do
  if !(link_card = subfield(:wikirate_link)) || link_card.content.empty?
    errors.add(:link, "does not exist.")
    return
  ends
  link_card.content.strip!
  @url = link_card.content

  # used to be restricted to the sourcebox=true case
  # I don't see why we shouldn't do this always  -pk
  validate_url

  duplication_check
  link_card.director.catch_up_to_stage :validate
  return if link_card.errors.present?
  if file_link?
    download_and_add_file
  elsif sourcebox?
    populate_title_and_description
  end
end

def populate_website?
  !subfield("website").present? && subfield(:wikirate_link).present? &&
    errors.empty?
end

def validate_url
  # url refers to a wikirate source card
  if url_card
    replace_with_url_card if valid_url_card?
  elsif !url? || wikirate_url?
    errors.add :source, "does not exist."
  end
end

def valid_url_card?
  return true if url_card.type_code == :source
  errors.add :source, "must be a valid URL or a WikiRate source"
  false
end

def replace_with_url_card
  clear_subcards
  self.name = url_card.name
  abort :success
end

def duplication_check
  return unless duplicates.any?
  duplicated_name = duplicates.first.name.left
  if sourcebox?
    remove_subfield(:wikirate_link)
    self.name = duplicated_name
    abort :success
  else
    errors.add :link,
               "exists already. <a href='/#{duplicated_name}'>"\
               "Visit the source.</a>"
  end
end

def duplicates
  @duplicates ||= Self::Source.find_duplicates url
end

def generate_pdf
  puts "generating pdf"
  kit = PDFKit.new url, "load-error-handling" => "ignore"
  Dir::Tmpname.create(["source", ".pdf"]) do |path|
    kit.to_file(path)
    file_card.update_attributes!(file: ::File.open(path)) if ::File.exist?(path)
  end
rescue => e
  Rails.logger.info "failed to convert source page to pdf #{e.message}"
end

def url
  @url ||= (wikirate_link && wikirate_link.strip) || ""
end

def url?
  url.start_with?("http://", "https://")
end

def wikirate_url?
  return false unless Card::Env[:protocol] && Card::Env[:host]
  url.start_with? "#{Card::Env[:protocol]}#{Card::Env[:host]}"
end

def url_card
  @url_card ||=
    if wikirate_url?
      # try to convert the link to source card,
      # easier for users to add source in +source editor
      uri = URI.parse(URI.unescape(url))
      Card[uri.path]
    else
      Card[url]
    end
end

def download_and_add_file
  return unless url.present? && within_file_size_limit?
  file_url = Addressable::URI.escape url
  add_subfield :file, remote_file_url: file_url, type_id: FileID, content: "dummy"
  source_type = subfield(:source_type)
  source_type.content = "[[#{:file.cardname}]]"
  remove_subfield :wikirate_link
  reset_patterns
  include_set_modules
rescue # if open raises errors just treat the source as a normal source
  Rails.logger.info "failed to get the file from link"
end

def header
  @header ||= fetch_http_header
end

def fetch_http_header
  curl = Curl::Easy.new url
  curl.follow_location = true
  curl.max_redirects = 5
  curl.http_head
  curl.header_str
rescue => error
  Rails.logger.info "Fail to extract header from the #{url}, #{error.message}"
  ""
end

def max_size
  # prevent from showing file too big while users are adding a link source
  (max = Card["*upload max"]) ? max.db_content.to_i : 5
end

def file_type
  @file_type ||= header[/.*Content-Type: (.*)\r\n/, 1] || ""
end

def file_size
  @file_size ||= header[/.*Content-Length: (.*)\r\n/, 1].to_i
end

def file_link?
  file_type.present? && !file_type.start_with?("text/html", "image/", "*/*")
end

def html_link?
  file_type.present? && file_type.start_with?("text/html")
end

def within_file_size_limit?
  file_size.to_i <= max_size.megabytes
end

def sourcebox?
  Card::Env.params[:sourcebox] == "true"
end

def populate_title_and_description
  thumbnail = LinkThumbnailer.generate url
  add_title thumbnail
  add_description thumbnail
rescue
  Rails.logger.info "failed to extract information from #{url}"
end

def add_title thumbnail
  return if subfield("title") || thumbnail.title.empty?
  add_subcard "+title", content: thumbnail.title
end

def add_description thumbnail
  return if subfield(:description) || thumbnail.description.empty?
  add_subfield :description, content: thumbnail.description
end

format :json do
  def essentials
    super.merge source_url: card.url
  end
end
