card_accessor :file, type: :file
card_accessor :wikirate_link, type: :phrase
card_accessor :wikirate_website, type: :pointer

alias_method :link_card, :wikirate_link_card

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

event :duplication_check, after: :validate_link, on: :create do
  return unless duplicates.any?
  duplicated_name = duplicates.first.name.left
  if sourcebox?
    remove_subfield(:wikirate_link)
    self.name = duplicated_name
    save_in_session_card true
    abort :success
  else
    errors.add :link,
               "exists already. #{link_to_card duplicated_name, 'Visit the source.'}"
    abort :failure
  end
end

event :process_link, after: :duplication_check, on: :create do
  link_card.director.catch_up_to_stage :validate
  return if link_card.errors.present?

  download_and_add_file || populate_title_and_description
end

def populate_website?
  !subfield(:wikirate_website).present? && subfield(:wikirate_link).present? &&
    errors.empty?
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

def html_link?
  file_type.present? && file_type.start_with?("text/html")
end

def sourcebox?
  Card::Env.params[:sourcebox] == "true"
end

def populate_title_and_description
  return unless sourcebox?
  thumbnail = LinkThumbnailer.generate url

  add_title thumbnail
  add_description thumbnail
rescue
  Rails.logger.info "failed to extract information from #{url}"
end

def add_title thumbnail
  return if subfield(:wikirate_title) || thumbnail.title.empty?
  add_subfield :wikirate_title, content: thumbnail.title
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
