
def self.find_duplicates url
  duplicate_wql = { right: Card[:wikirate_link].name, content: url, left: { type_id: Card::SourceID } }
  Card.search duplicate_wql
end

format :json do
  view :metadata do |args|
    metadata = MetaData.new
    url = Card::Env.params[:url] || args[:url] || ""
    if url.empty?
      metadata.error = "empty url"
      return metadata.to_json
    end
    begin
      metadata.website = URI(url).host
    rescue
    end
    unless metadata.website
      metadata.error = "invalid url"
      return metadata.to_json
    end
    duplicates = Source.find_duplicates url
    if duplicates.any?
      origin_page_card = duplicates.first.left
      title = fetch_field_content origin_page_card, "title"
      description = fetch_field_content origin_page_card, "description"
      image_url = fetch_field_content origin_page_card, "image_url"
      metadata.set_meta_data title, description, image_url
    else
      begin
        preview = LinkThumbnailer.generate url
        image_url = preview.images.first.src.to_s unless preview.images.empty?
          metadata.set_meta_data preview.title, preview.description, image_url
      rescue
      end
    end
    metadata.to_json
  end

  def fetch_field_content card, field
    unless (field_card = Card["#{card.name}+#{field}"])
      return block_given? ? yield : ""
    end
    field_card.content
  end

  def valid_content_type? content_type, user_agent
    allow_content_type = ["image/png", "image/jpeg"]
    # for case, "text/html; charset=iso-8859-1"
    allow_content_type.include?(content_type) ||
      content_type.start_with?("text/html", "text/plain") ||
      firefox?(user_agent)
  end

  def valid_x_frame_options? options
    return true unless options
    !options.upcase.include?("DENY") &&
      !options.upcase.include?("SAMEORIGIN")
  end

  def iframable_options url
    # escape space in url, eg,
    # http://www.businessweek.com/articles/2014-10-30/
    # tim-cook-im-proud-to-be-gay#r=most popular
    url.gsub!(/ /, "%20")
    curl = Curl::Easy.new(url)
    curl.follow_location = true
    curl.max_redirects = 5
    curl.http_head
    header_str = curl.header_str
    [header_str[/.*X-Frame-Options: (.*)\r\n/, 1],
     header_str[/.*Content-Type: (.*)\r\n/, 1]]
  end

  def firefox? user_agent
    user_agent ? user_agent =~ /Firefox/ : false
  end

  def iframable? url, user_agent
    return false unless url.present?
    x_frame_options, content_type = iframable_options url
    valid_x_frame_options?(x_frame_options) &&
      valid_content_type?(content_type, user_agent)
  rescue => error
    Rails.logger.error error.message
    return false
  end

  view :check_iframable do |_args|
    user_agent = request ? request.env["HTTP_USER_AGENT"] : nil
    { result: !!iframable?(params[:url], user_agent) }
  end
end

# hash result for iframe checking
MetaData = Struct.new :title, :description, :image_url, :website, :error do
  def initialize title="", description="", image_url="", website="", error=""
    super
  end

  def set_meta_data title, desc, image_url
    self.title = title
    self.description = desc
    self.image_url = image_url
  end
end
