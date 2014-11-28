require 'open-uri'
format :html do

  def company_and_topic_match? source_name, company, topic
    if !source_name
      return false
    end
    company_pointer = Card[source_name+"+company"]
    topic_pointer = Card[source_name+"+topic"]

    if !company_pointer or !topic_pointer
      return false
    end
    if company_pointer.item_names.include?(company) and topic_pointer.item_names.include?(topic)
      return true
    end
    false
  end
  def first_or_add first_name, type_name, show_add_link
    no_content_class = "no-content"
    content = if first_name
      no_content_class = ""
      %{
        <a href="#{first_name}" target="_blank">
          <span class="#{type_name}-name">#{first_name}</span>
        </a>
      }  
    else
      if show_add_link
        %{<a id='add-#{type_name}-link' href='#' >Add #{type_name.humanize}</a>}
      else
        no_content_class=""
        ""
      end
    end
    %{
      <div class="#{type_name}-name #{no_content_class}">
        #{content}
      </div>
    }
  end
  def first_name_of_pointer pointer_card
    if pointer_card
      names = pointer_card.item_names
      if names.length > 0
        return names[0]
      end
    end
    nil
  end
  view :company_and_topic_detail do |args|
    company = Card::Env.params[:company]
    topic = Card::Env.params[:topic]
    url = Card::Env.params[:url]
    from_certh = Card::Env.params[:fromcerth] == "true"
    dropdown_class = ""
    source = Self::Webpage.find_duplicates url
    source_name = source.first.left.name if source.any?
    #if company and topic match exisiting source, show it as a exisiting source
    if from_certh and !company_and_topic_match? source_name,company,topic
      dropdown_class = "no-dropdown"
      first_company = first_or_add company,"company",false
      first_topic = first_or_add topic,"topic",false
    else    
      company = nil
      topic = nil
      if source_name 
        company = first_name_of_pointer Card.fetch source_name+"+company"    
        topic = first_name_of_pointer Card.fetch source_name+"+topic"
      end
      first_company = first_or_add company,"company",!from_certh
      first_topic = first_or_add topic,"topic",!from_certh
    end
    %{
        #{first_company}
        #{first_topic}
        <a href="#" id="company-and-topic-detail-link" class="#{dropdown_class}">
          <i class="fa fa-caret-square-o-down"></i>
        </a>
      } 
  end


  def show_options source_from_certh,source_page_name,url
    if source_from_certh
      %{
        <div id="mark-irrelevant" >
          <a href="#" id="mark-irrelevant-button" class="button-primary button-secondary">
            <i class="fa fa-exclamation-triangle">
            </i>
            <span>Irrelevant</span>
          </a>
        </div>
        <div id="mark-relevant" >
          <a href="#" id="mark-relevant-button" class="button-primary">
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
      result+=%{
        <div id="claim-count">
        #{
        "<a class='show-link-in-popup' href='/#{source_page_name}+source claim list' target='_blank'>
          <span class='claim-count'>
            #{claim_count}
          </span>
          <span class='claim-count'>Claims</span>
        </a>" if claim_count != 0}
        </div>} 
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
  def is_iframable? url, request
    allow_content_type = ["text/html","text/plain","image/png","image/jpeg"]
    return false if !url or url.length == 0
    begin 
      # escape space in url, eg, http://www.businessweek.com/articles/2014-10-30/tim-cook-im-proud-to-be-gay#r=most popular
      url.gsub!(/ /, '%20')
      uri = open(url)
      xFrameOptions = uri.metas["x-frame-options"]
      is_firefox = request.env['HTTP_USER_AGENT'] =~ /Firefox/
      return false if xFrameOptions and ( xFrameOptions.upcase.include? "DENY" or xFrameOptions.upcase.include? "SAMEORIGIN" )
      return false if !allow_content_type.include?(uri.content_type) and  !is_firefox
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
      result = {:result => is_iframable?( url, request ) }
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
