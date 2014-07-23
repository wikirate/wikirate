require 'link_thumbnailer'

event :process_source_url, :before=>:process_subcards, :on=>:create, :when=>proc{ 
   |c| Card::Env.params[:sourcebox] == 'true'
  } do
  byebug
  linkparams = subcards["+#{ Card[:wikirate_link].name }"]
  url = linkparams && linkparams[:content] or raise "don't got it"
  if url.length == 0
    errors.add :link, "is empty" 
  else
    duplicates = find_duplicates url
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


def find_duplicates url
  #need to check if content changed...
   duplicate_wql = { :right=>Card[:wikirate_link].name, :content=>url ,:left=>{:type_id=>Card::WebpageID}}
#  duplicate_wql[:not] = { :id => id } if id
  duplicates = Card.search duplicate_wql
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

  view :missing do |args|
    _view_link args
  end

end  


