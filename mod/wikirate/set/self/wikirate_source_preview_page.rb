require 'open-uri'
format :html do

  def company_and_topic_match? source_name, company, topic
    if !source_name
      return false
    else
      company_pointer = Card[source_name+"+company"]
      topic_pointer = Card[source_name+"+topic"]
      if !company_pointer or !topic_pointer
        return false
      else
        if company_pointer.item_names.include?(company) and topic_pointer.item_names.include?(topic)
          return true
        end
      end
    end
    false
  end

  view :company_and_topic_detail do |args|
    company = Card::Env.params[:company]
    topic = Card::Env.params[:topic]
    url = Card::Env.params[:url]
    from_certh = Card::Env.params[:fromcerth]
    from_certh = from_certh == "true"
    
    first_company = %{<a id='add-company-link' href='#' >Add Company</a>}
    first_topic =  %{<a id='add-topic-link' href='#' >Add Topic</a>}
    #no-content class is for "Add company" and "Add Topic"
    company_no_content_class = "no-content"
    topic_no_content_class = "no-content"
    dropdown_style = ""
    source = Self::Webpage.find_duplicates url
    source_name = source.first.left.name if source.any?
    #if company and topic match exisiting source, show it as a exisiting source
    if from_certh and !company_and_topic_match? source_name,company,topic
      dropdown_style = "display:none;"
      first_company = if company
        %{<a href="#{company}" target="_blank"><span class="company-name">#{company}</span></a>} 
      else
        company_no_content_class = ""
        ""
      end
      first_topic = if topic 
        %{<a href="#{topic}" target="_blank"><span class="topic-name">#{topic}</span></a>}  
      else
        topic_no_content_class = ""
        ""
      end
    else    
      if source_name 
        company_card = Card[source_name+"+company"] 
        topic_card = Card[source_name+"+topic"] 
        if company_card
          companies = company_card.item_names
          if companies.length > 0 
            first_company = %{<a href="#{companies[0]}" target="_blank"><span class="company-name">#{companies[0]}</span></a>}  
            company_no_content_class = ""
          end
        end
        if topic_card
          topics = topic_card.item_names
          if topics.length > 0 
            first_topic  = %{<a href="#{topics[0]}" target="_blank"><span class="topic-name">#{topics[0]}</span></a>} 
            topic_no_content_class = ""
          end
        end   
      end
    end
    %{
        <div class="company-name #{company_no_content_class}">
          #{first_company}
        </div>
        <div class="topic-name #{topic_no_content_class}">
          #{first_topic}
        </div>
        <a href="#" id="company-and-topic-detail-link" style="#{dropdown_style}">
          <i class="fa fa-caret-square-o-down"></i>
        </a>
      } 
  end
  def show_options source_from_certh,source_page_name,url
    if source_from_certh
      %{
        <div id="mark-irrelevant" class="button-primary button-secondary">
          <a href="#" id="mark-irrelevant-button">
            <i class="fa fa-exclamation-triangle">
            </i>
            <span>Irrelevant</span>
          </a>
        </div>
        <div id="mark-relevant" class="button-primary">
          <a href="#" id="mark-relevant-button">
            <i class="fa fa-exclamation-triangle">
            </i>
            <span>Relevant</span>
          </a>
        </div>
      }
    else
      
      related_claim_wql = {:left=>{:type=>"Claim"},:right=>"source",:link_to=>"#{source_page_name}",:return=>"count"}
      claim_count = Card.search related_claim_wql

      result = %{
        <div id="source-page-link" class="mark-irrelevant-button" >
          <a href="/#{source_page_name}" id="source-page-button" target="_blank">
            Source Details
            <i class="fa fa-chevron-circle-right"></i>
          </a>
          <a href="#{url}" id="direct-link-button" target="_blank">
            Direct Link
            <i class="fa fa-chevron-circle-right"></i>
          </a>
        </div>
        <div id="make-claim" class="button-primary">
          <a href="#" id="make-a-claim-button">
            <span>Make a Claim</span>
          </a>
        </div>
      }
      result+=%{<div id="claim-count">#{"<a class='show-link-in-popup' href='/#{source_page_name}+source claim list' target='_blank'>#{claim_count} Claims</a>" if claim_count != 0}</div>} 
      result
    end
  end
  view :source_preview_options do |args|
    company = Card::Env.params[:company]
    topic = Card::Env.params[:topic]
    url = Card::Env.params[:url]
    from_certh = Card::Env.params[:fromcerth]
    from_certh = from_certh == "true"
    source = Self::Webpage.find_duplicates url
    source_name = source.first.left.name if source.any?
    #show options as existing source one if it is from certh and the company and topic match the source's one
    if from_certh and !company_and_topic_match? source_name,company,topic
      show_options true, source_name ,url
    else
      show_options false, source_name ,url
    end
  end
  view :source_name do |args|
    url = Card::Env.params[:url]
    source_name = ""
    if url 
      source = Self::Webpage.find_duplicates url
      source_name = source.first.left.name if source.any?
    end
    source_name
  end
end

format :json do
  def is_iframable? url
    return false if !url or url.length == 0
    begin 
      # escape space in url, eg, http://www.businessweek.com/articles/2014-10-30/tim-cook-im-proud-to-be-gay#r=most popular
      url.gsub!(/ /, '%20')
      uri = open(url)
      xFrameOptions = uri.metas["x-frame-options"]
      return false if xFrameOptions and ( xFrameOptions.upcase.include? "DENY" or xFrameOptions.upcase.include? "SAMEORIGIN" )
      return false if uri.content_type != "text/html"
    rescue => error
      Rails.logger.error error.message
      return false
    end
    true
  end
  view :get_user_id do |args|
    result = {:id=>Auth.current_id}
  end
  view :check_source do |args|
    url = Card::Env.params[:url]
    result = {:result => false }
    if url
      source = Self::Webpage.find_duplicates url
      result = {:result => true, :source => source.first.left.name} if source.any?
    end
    result
  end
  view :check_iframable do |args|
    url = Card::Env.params[:url]
    if url
      result = {:result => is_iframable?( url ) }
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
    company_id = Card[company].id if Card[company] and Card[company].type_id == Card::WikirateCompanyID
    topic_id = Card[topic].id if Card[topic] and Card[topic].type_id == Card::WikirateTopicID
    
    if company_id and topic_id and url and type
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
