card_accessor :vote_count, :type=>:number, :default=>"0"
card_accessor :upvote_count, :type=>:number, :default=>"0"
card_accessor :downvote_count, :type=>:number, :default=>"0"
card_accessor :direct_contribution_count, :type=>:number, :default=>"0"
card_accessor :contribution_count, :type=>:number, :default=>"0"

def indirect_contributer_search_args
  [
    {:right_id=>VoteCountID, :left=>self.name }
  ]
end

require 'link_thumbnailer'


event :vote_on_create_webpage, :on=>:create, :after=>:store, :when=> proc{ |c| Card::Auth.current_id != Card::WagnBotID }do
  Auth.as_bot do
    vc = vote_count_card
    vc.supercard = self
    vc.vote_up
    vc.save!
  end
end


event :process_source_url, :before=>:process_subcards, :on=>:create do
#, :when=>proc{    |c| Card::Env.params[:sourcebox] == 'true'  } do
  
  linkparams = subcards["+#{ Card[:wikirate_link].name }"]
  url = linkparams && linkparams[:content] or raise "don't got it"
  if url.length == 0
    errors.add :link, "is empty" 
  else
    duplicates = Self::Webpage.find_duplicates url
    if duplicates.any?
      duplicated_name = duplicates.first.cardname.left
      if Card::Env.params[:sourcebox] == 'true'
        self.name = duplicated_name
        abort :success
      else
        errors.add :link, "exists already. <a href='/#{duplicated_name}'>Visit the source.</a>"   
      end
    end
  end
  parse_source_page url if Card::Env.params[:sourcebox] == 'true'
end

def parse_source_page url
  if errors.empty?
    preview = LinkThumbnailer.generate url
    if preview.images.length > 0
     subcards["+image url" ] = preview.images.first.src.to_s
    end
    subcards["+title"      ] = preview.title
    subcards["+description"] = preview.description
  end
rescue
  Rails.logger.info "Fail to extract information from the #{ url }"
end


event :autopopulate_website, :after=>:approve_subcards, :on=>:create do
  if link_card = subcards["+#{ Card[:wikirate_link].name }"] and link_card.errors.empty?
    host = link_card.instance_variable_get '@host'

    website = Card[:wikirate_website].name    
    website_card = Card.new :name=>"+#{website}", :content => "[[#{host}]]", :supercard=>self
    website_card.approve

    subcards["+#{website}"] = website_card
#    self.name = generate_name host
    
    if !Card.exists? host
      Card.create :name=>host, :type_id=>Card::WikirateWebsiteID
    end
  end
end

format :html do

  def company_and_topic_match? company, topic , url
    source = Self::Webpage.find_duplicates url
    return false if ! source.any?
    source_name = source.first.left.name 
    company_pointer = Card[source_name].fetch :trait=>:wikirate_company
    topic_pointer = Card[source_name].fetch :trait=>:wikirate_topic
    if company_pointer and topic_pointer
      if company_pointer.item_names.include?(company) and topic_pointer.item_names.include?(topic)
        return true 
      end
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

  view :preview ,:tags=>:unknown_ok do |args|
    content = wrap args do
      [
        content_tag(:div, web_link("/", :text=>raw( nest Card["*logo"], :view=>:content, :size=>:medium )), {:class=> "top-bar-icon"},false),
        render_company_and_topic_detail(args),
        content_tag(:div, "", {:id=>"webpage-preview", :class=> "webpage-preview"},false)
      ]
    end
    %{
      <div id="logo-bar" class="top-bar nodblclick">
        #{content}
      </div>
    }
  end

  view :company_and_topic_detail ,:tags=>:unknown_ok  do |args|

    company = Card::Env.params[:company]
    topic = Card::Env.params[:topic]
    url = Card::Env.params[:url]

    from_certh = !card.real? 

    if card.real?
      company_card = card.fetch(:trait=>:wikirate_company)
      topic_card = card.fetch(:trait=>:wikirate_topic)
      url_card = card.fetch(:trait=>:wikirate_link)
      company = company_card ? card.fetch(:trait=>:wikirate_company).item_names.first : nil
      topic = topic_card ? card.fetch(:trait=>:wikirate_topic).item_names.first : nil
      url = company_card ? card.fetch(:trait=>:wikirate_link).item_names.first : nil
      
    end
    
    dropdown_class = ""
    
    source_name = from_certh ? card.name : nil
    #if company and topic match exisiting source, show it as a exisiting source
    option_html = ""
    if from_certh and not company_and_topic_match? company,topic, url
      dropdown_class = "no-dropdown"
      first_company = first_or_add company,"company",false
      first_topic = first_or_add topic,"topic",false
      option_html = show_options true, source_name ,url
    else    
      first_company = first_or_add company,"company",!from_certh
      first_topic = first_or_add topic,"topic",!from_certh
      option_html = show_options false, source_name ,url
    end

    %{
      <div class="menu-options">
        #{option_html}
      </div>
      <div id="company-and-topic" class="company-and-topic">
        #{first_company}
        #{first_topic}
        <a href="#" id="company-and-topic-detail-link" class="#{dropdown_class}">
          <i class="fa fa-caret-square-o-down"></i>
        </a>
      </div>
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

  def edit_slot args
    # see claim.rb for explanation of core_edit
    super args.merge(:core_edit=>true)
  end

  view :content do |args|
    add_name_context
    super args
  end
 
  view :missing do |args|
    _view_link args
  end
  
  view :titled, :tags=>:comment do |args|
    render_titled_with_voting args
  end
  
  view :open do |args|
    super args.merge( :custom_source_header=>true )
  end
  
  view :header do |args|
    if args.delete(:custom_source_header)
      render_header_with_voting
    else
      super(args)
    end
  end

end  


