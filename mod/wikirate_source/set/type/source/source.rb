card_accessor :vote_count, :type=>:number, :default=>"0"
card_accessor :upvote_count, :type=>:number, :default=>"0"
card_accessor :downvote_count, :type=>:number, :default=>"0"
card_accessor :direct_contribution_count, :type=>:number, :default=>"0"
card_accessor :contribution_count, :type=>:number, :default=>"0"

card_accessor :metric, :type=>:pointer
card_accessor :year, :type=>:pointer

def indirect_contributor_search_args
  [
    {:right_id=>VoteCountID, :left=>self.name }
  ]
end

require 'link_thumbnailer'


event :vote_on_create_source, :on=>:create, :after=>:store, :when=> proc{ |c| Card::Auth.current_id != Card::WagnBotID }do
  Auth.as_bot do
    vc = vote_count_card
    vc.supercard = self
    vc.vote_up
    vc.save!
  end
end

event :check_source, :after=>:approve_subcards, :on=>:create do
  binding.pry
  source_cards = [subcards["+#{ Card[:wikirate_link].name }"],subcards["+File"],subcards["+Text"]].compact
  if source_cards.length > 1 
    errors.add :source, "Please only add one type of source"
  elsif source_cards.length == 0
    errors.add :source, "Please at least add one type of source"
  end
end

event :process_source_url, :before=>:process_subcards, :on=>:create do
#, :when=>proc{    |c| Card::Env.params[:sourcebox] == 'true'  } do
binding.pry
  return if subcards["+File"] or subcards["+Text"]
  linkparams = subcards["+#{ Card[:wikirate_link].name }"]
  url = linkparams && linkparams[:content] or raise "don't got it"
  if url.length != 0
    # errors.add :link, "is empty" 
  # else
    if Card::Env.params[:sourcebox] == 'true'
      if cite_card = Card[url] 
        if cite_card.type_code != :source
          errors.add :source, " can only be source type or valid URL."     
        else
          self.name = cite_card.name
          abort :success
        end
      else
        errors.add :source, " does not exist." if not (url.start_with?"http://" or url.start_with?"https://")
      end
    end
    duplicates = Self::Source.find_duplicates url
    if duplicates.any?
      duplicated_name = duplicates.first.cardname.left
      if Card::Env.params[:sourcebox] == 'true'
        self.name = duplicated_name
        abort :success
      else
        errors.add :link, "exists already. <a href='/#{duplicated_name}'>Visit the source.</a>"   
      end
    end
    parse_source_page url if Card::Env.params[:sourcebox] == 'true'
  end
  
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
  website = Card[:wikirate_website].name  
  if link_card = subcards["+#{ Card[:wikirate_link].name }"] and link_card.errors.empty?  
    website_subcard = subcards["+#{website}"]
    unless website_subcard
      host = link_card.instance_variable_get '@host' 
      website_card = Card.new :name=>"+#{website}", :content => "[[#{host}]]", :supercard=>self
      website_card.approve
      subcards["+#{website}"] = website_card  
      if !Card.exists? host
        Card.create :name=>host, :type_id=>Card::WikirateWebsiteID
      end
    end
  end
  if subcards["+File"]
    unless website_subcard  
      website_card = Card.new :name=>"+#{website}", :content => "[[wikirate.org]]", :supercard=>self
      website_card.approve
      subcards["+#{website}"] = website_card  
    end
  end
end

format :html do

  def edit_slot args
    # see claim.rb for explanation of core_edit
    super args.merge(:core_edit=>true)
  end

  view :metric_import_link do |args|
    file_card = Card[card.name+"+File"]
    if file_card and mime_type = file_card.content.split("\n")[1] and mime_type == "text/csv"
      card_link file_card, {:text=>"Import to metric values",:path_opts=>{:view=>:import}}
    else
      ""
    end
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

