
def self.find_duplicates url
  duplicate_wql = { :right=>Card[:wikirate_link].name, :content=>url ,:left=>{:type_id=>Card::WebpageID}}
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
    duplicates = Webpage.find_duplicates url
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
  def is_iframable? url, user_agent
    allow_content_type = ["text/html","text/plain","image/png","image/jpeg"]
    return false if !url or url.length == 0
    begin 
      # escape space in url, eg, http://www.businessweek.com/articles/2014-10-30/tim-cook-im-proud-to-be-gay#r=most popular
      url.gsub!(/ /, '%20')
      uri = open(url, :allow_redirections => :safe)
      xFrameOptions = uri.meta["x-frame-options"]
      is_firefox = user_agent ? user_agent =~ /Firefox/ : false
      return false if xFrameOptions and ( xFrameOptions.upcase.include? "DENY" or xFrameOptions.upcase.include? "SAMEORIGIN" )
      return false if !allow_content_type.include?(uri.content_type) and  !is_firefox
    rescue => error
      Rails.logger.error error.message
      return false
    end
    true
  end
  
  view :check_iframable do |args|
    url = Card::Env.params[:url]
    if url
      result = {:result => is_iframable?( url, request ? request.env['HTTP_USER_AGENT'] : nil ) }
    else
      result = {:result => false }
    end
    result
  end
  view :feedback ,:perms=>lambda { |r| Auth.signed_in? } do |args|
    url = Card::Env.params[:url]
    company = Card::Env.params[:company]
    topic = Card::Env.params[:topic]
    
    type = Card::Env.params[:type]

    
    result = {:result => false }
    case type
    when "either"
      rel_topic_score = -1
      rel_company_score = -1     
    when "company"
      rel_topic_score = 1
      rel_company_score = -1
    when "topic"
      rel_topic_score = -1
      rel_company_score = 1
    when "relevant"
      rel_topic_score = 1
      rel_company_score = 1
    else
      return result
    end
    user_id = Auth.current_id
    company_id, company_name = Card[company].id, Card[company].name if Card[company] and Card[company].type_id == Card::WikirateCompanyID
    topic_id, topic_name = Card[topic].id, Card[topic].name if Card[topic] and Card[topic].type_id == Card::WikirateTopicID
    
    if company_id and topic_id and url and type
      query = { url: url, 
                user_id: user_id,
                rel_topic_score: rel_topic_score,
                rel_company_score: rel_company_score, 
                company_id: company_id, 
                company: company_name, 
                topic_id: topic_id, 
                topic: topic_name}
                .to_query
      request_url = "http://mklab.iti.gr/wikirate-sandbox/api/index.php/relevance/?#{query}"
      uri = URI.parse(request_url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      result_from_certh = JSON.parse(response.body)
      #TODO: log them to a file
      result = {:result => true, :result_from_certh => result_from_certh["results"]["code"],:msg=>result_from_certh["results"]["msg"]}
    end
    result
  end
end

class MetaData  
  attr_accessor :title,:description,:image_url,:website,:error
  def initialize()  
    @title = ""
    @description = ""
    @image_url  =""
    @website = ""
    @error = ""
  end  
  def set_meta_data title,desc,image_url
    @title = title
    @description = desc
    @image_url = image_url
  end
end  

