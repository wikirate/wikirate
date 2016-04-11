
def self.find_duplicates url
  duplicate_wql = { :right=>Card[:wikirate_link].name, :content=>url ,:left=>{:type_id=>Card::SourceID}}
  duplicates = Card.search duplicate_wql
end

format :json do
  view :metadata do |args|
    metadata = MetaData.new
    url = Card::Env.params[:url]||args[:url] ||""
    if url.empty?
      metadata.error = 'empty url'
      return metadata.to_json
    end
    begin      
      metadata.website = URI(url).host
    rescue    
    end
    if !metadata.website
      metadata.error = 'invalid url' 
      return metadata.to_json
    end
    duplicates = Source.find_duplicates url
    if duplicates.any?
      origin_page_card = duplicates.first.left
      title =  Card["#{origin_page_card.name}+title"] ? Card["#{origin_page_card.name}+title"].content : ""
      description =  Card["#{origin_page_card.name}+description"] ? Card["#{origin_page_card.name}+description"].content : ""
      image_url = Card["#{origin_page_card.name}+image_url"] ? Card["#{origin_page_card.name}+image_url"].content : ""
      metadata.set_meta_data title,description,image_url
    else
      begin 
        preview = LinkThumbnailer.generate url
        if preview.images.length > 0
          image_url = preview.images.first.src.to_s
        end
          metadata.set_meta_data preview.title, preview.description, image_url
      rescue
      end
    end
    metadata.to_json
  end
  def valid_content_type? content_type, user_agent
    allow_content_type = ['image/png', 'image/jpeg']
    # for case, "text/html; charset=iso-8859-1"
    allow_content_type.include?(content_type) ||
      content_type.start_with?('text/html') ||
      content_type.start_with?('text/plain') ||
      firefox?(user_agent)
  end

  def invalid_x_frame_options? options
    options &&
      (options.upcase.include?('DENY') ||
      options.upcase.include?('SAMEORIGIN'))
  end

  def iframable_options url
    # escape space in url, eg,
    # http://www.businessweek.com/articles/2014-10-30/
    # tim-cook-im-proud-to-be-gay#r=most popular
    url.gsub!(/ /, '%20')
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
    return false if !url || url.empty?
    begin
      x_frame_options, content_type = iframable_options url
      if invalid_x_frame_options?(x_frame_options) ||
         !valid_content_type?(content_type, user_agent)
        return false
      end
    rescue => error
      Rails.logger.error error.message
      return false
    end
    true
  end
  
  view :check_iframable do |_args|
    url = Card::Env.params[:url]
    if url
      iframe =
        iframable?(url, request ? request.env['HTTP_USER_AGENT'] : nil)
      result = { result: iframe }
    else
      result = { result: false }
    end
    result
  end
end

# hash result for iframe checking
class MetaData
  attr_accessor :title, :description, :image_url, :website, :error

  def initialize
    @title = ''
    @description = ''
    @image_url = ''
    @website = ''
    @error = ''
  end

  def set_meta_data title, desc, image_url
    @title = title
    @description = desc
    @image_url = image_url
  end
end  

