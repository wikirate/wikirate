
card_accessor :wikirate_link, type: :phrase
card_accessor :wikirate_website, type: :pointer

format :html do
  view :original_link do |args|
    link_to (args[:title] || 'Visit Source'), card.wikirate_link
  end
end

def populate_website?
  !subfield('website').present? && subfield(:wikirate_link).present?
end

event :autopopulate_website,
      :validate, on: :create, when: proc { |c| c.populate_website? } do
  link = subfield(:wikirate_link).content
  uri = URI.parse(link)
  host = uri.host
  add_subfield :wikirate_website, content: "[[#{host}]]"
  return if Card.exists?(host)
  add_subcard host, type_id: Card::WikirateWebsiteID
end

def handle_source_box_source url
  cite_card = get_card(url)
  if cite_card
    if cite_card.type_code != :source
      errors.add :source, ' can only be source type or valid URL.'
    else
      self.name = cite_card.name
      abort :success
    end
    # if !wikirate url and is a url
    # if !url
  elsif !url?(url) || wikirate_url?(url)
    errors.add :source, ' does not exist.'
  end
end

def duplication_check url
  duplicates = Self::Source.find_duplicates url
  return unless duplicates.any?
  duplicated_name = duplicates.first.cardname.left
  if Card::Env.params[:sourcebox] == 'true'
    self.name = duplicated_name
    abort :success
  else
    errors.add :link,
               "exists already. <a href='/#{duplicated_name}'>"\
               'Visit the source.</a>'
  end
end

event :process_source_url, :validate, after: :check_source, on: :create do
  if !(link_card = subfield(:wikirate_link)) || link_card.content.empty?
    errors.add(:link, 'does not exist.')
    return
  end
  url = link_card.content
  if Card::Env.params[:sourcebox] == 'true'
    handle_source_box_source url
  end
  duplication_check url
  return if errors.present?
  file_type, size = file_type_and_size url
  is_file_link = file_link? file_type
  if is_file_link && within_file_size_limit?(size)
    download_file_and_add_to_plus_file url
    remove_subfield(:wikirate_link)
    reset_patterns
    include_set_modules
  elsif Card::Env.params[:sourcebox] == 'true' && !is_file_link
    parse_source_page url
  end
end

def url? url
  url.start_with?('http://', 'https://')
end

def wikirate_url? url
  wikirate_url = "#{Card::Env[:protocol]}#{Card::Env[:host]}"
  url.start_with?(wikirate_url)
end

def get_card url
  if wikirate_url?(url)
    # try to convert the link to source card,
    # easier for users to add source in +source editor
    uri = URI.parse(URI.unescape(url))
    Card[uri.path]
  else
    Card[url]
  end
end

def download_file_and_add_to_plus_file url
  url.gsub!(/ /, '%20')
  add_subfield :file, remote_file_url: url, type_id: FileID, content: 'dummy'
  # remove_subfield :wikirate_link
rescue  # if open raises errors , just treat the source as a normal source
  Rails.logger.info 'Fail to get the file from link'
end

def get_curl url
  curl = Curl::Easy.new(url)
  curl.follow_location = true
  curl.max_redirects = 5
  curl.http_head
  curl
end

def max_size
  # prevent from showing file too big while users are adding a link source
  (max = Card['*upload max']) ? max.db_content.to_i : 5
end

def file_type_and_size url
  # just got the header instead of downloading the whole file
  curl = get_curl(url)
  content_type = curl.head[/.*Content-Type: (.*)\r\n/, 1]
  content_size = curl.head[/.*Content-Length: (.*)\r\n/, 1].to_i
  [content_type, content_size]
rescue
  Rails.logger.info "Fail to extract header from the #{url}"
  ['', '']
end

def file_link? mime_type
  !mime_type.empty? && !mime_type.start_with?('text/html', 'image/')
end

def within_file_size_limit? size
  size.to_i <= max_size.megabytes
end

def parse_source_page url
  preview = LinkThumbnailer.generate url
  # if preview.images.length > 0
  #   add_subcard '+image url', content: preview.images.first.src.to_s
  # end
  unless subfield('title')
    add_subcard '+title', content: preview.title
  end
  return if subfield('Description')
  add_subcard '+description', content: preview.description
rescue
  Rails.logger.info "Fail to extract information from the #{url}"
end
