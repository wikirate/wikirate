card_accessor :vote_count, :type=>:number, :default=>"0"
card_accessor :upvote_count, :type=>:number, :default=>"0"
card_accessor :downvote_count, :type=>:number, :default=>"0"

require 'link_thumbnailer'

event :process_source_url, :before=>:process_subcards, :on=>:create, :when=>proc{ 
   |c| Card::Env.params[:sourcebox] == 'true'
  } do
  
  linkparams = subcards["+#{ Card[:wikirate_link].name }"]
  url = linkparams && linkparams[:content] or raise "don't got it"
  if url.length == 0
    errors.add :link, "is empty" 
  else
    duplicates = Self::Webpage.find_duplicates url
    if duplicates.any?
      self.name = duplicates.first.cardname.left
      abort :success
    end
  end

  parse_source_page url
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

  def edit_slot args
    # see claim.rb for explanation of core_edit
    super args.merge(:core_edit=>true)
  end

  view :content do |args|
    add_name_context
    super args
  end
 
  view :first_company_and_topic do |args|
    company_card = Card[card.name+"+company"]
    topic_card = Card[card.name+"+topic"]
    first_company = %{<a id='add-company-link' href='#' >Add Company</a>}
    first_topic =  %{<a id='add-topic-link' href='#' >Add Topic</a>}
    no_content = "no-content"
    if company_card
      companies = company_card.item_names
      if companies.length > 0 
        first_company = %{<a href="#{companies[0]}" target="_blank"><span class="company-name">#{companies[0]}</span></a>}  
        no_content = ""
      end
    end
    if topic_card
      topics = topic_card.item_names
      if topics.length > 0 
        first_topic  = %{<a href="#{topics[0]}" target="_blank"><span class="topic-name">#{topics[0]}</span></a>} 
        no_content = ""
      end
    end   
    %{
      <div class="company-name #{no_content}">
        #{first_company}
      </div>
      <div class="topic-name #{no_content}">
        #{first_topic}
      </div>
      <a href="#" id="company-and-topic-detail-link" style="">
        <i class="fa fa-caret-square-o-down"></i>
      </a>
    } 
    
  end

  view :missing do |args|
    _view_link args
  end
  
  view :titled, :tags=>:comment do |args|
    render_titled_with_voting args
  end
  
  view :header do |args|
    if args[:home_view] == :open and !args[:without_voting]
      render_header_with_voting
    else
      super(args)
    end
  end

end  


