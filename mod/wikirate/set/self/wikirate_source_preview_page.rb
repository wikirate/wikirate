format :json do
  def isIframable url,counter

    return false if counter>5
    begin 
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      request.initialize_http_header({"User-Agent" => "My Ruby Script"})

      response = http.request(request)
      if response.code=="301" or response.code=="302"
        #redirection
        counter+=1
        if response["location"].start_with?('/')
          redirect_location = "http://"+uri.host+":#{uri.port}"+response["location"]
        else
          redirect_location = response["location"]
        end
        return isIframable(redirect_location,counter)
      else
        xFrameOptions = response["x-frame-options"]
        if xFrameOptions and ( xFrameOptions.upcase.include? "DENY" or xFrameOptions.upcase.include? "SAMEORIGIN" )
          return false
        end
      end
    rescue => error
      Rails.logger.error error.message
      return false
    end
    return true
  end
  view :check_source do |args|
    url = Card::Env.params[:url]
    result = {:result => false }
    if url
      source = Self::Webpage.find_duplicates url
      result = {:result => true, :source => source.first.left.name} if source.any?
    end
    result.to_json
  end
  view :check_iframable do |args|
    url = Card::Env.params[:url]
    if url
      result = {:result => isIframable( url, counter=0 ) }
    else
      result = {:result => false }
    end
    result.to_json
  end
   view :feedback do |args|
    url = Card::Env.params[:url]
    company = Card::Env.params[:company]
    topic = Card::Env.params[:topic]
    
    type_of_irrelevance = Card::Env.params[:type_of_irrelevance]

    
    result = {:result => false }
    case type_of_irrelevance
    when "either"
      rel_topic_score = -1
      rel_company_score = -1     
    when "company"
      rel_topic_score = 1
      rel_company_score = -1
    when "topic"
      rel_topic_score = -1
      rel_company_score = 1
    else
      return result
    end
    user_id = Auth.current_id
    company_id = Card[company].id if Card[company]
    topic_id = Card[topic].id if Card[topic]
    
    if company_id and topic_id and url and type_of_irrelevance
      request_url = "http://mklab.iti.gr/wikirate-sandbox/api/index.php/relevance/?url=#{url}&user_id=#{user_id}&rel_topic_score=#{rel_topic_score}&rel_company_score=#{rel_company_score}&company_id=#{company_id}&topic_id=#{topic_id}"
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