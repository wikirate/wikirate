require 'curb'
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
  source_cards = [subcards["+#{ Card[:wikirate_link].name }"],subcards["+File"],subcards["+Text"]].compact
  if source_cards.length > 1
    errors.add :source, "Please only add one type of source"
  elsif source_cards.length == 0
    errors.add :source, "Please at least add one type of source"
  end
end

def has_file_or_text?
  file_card = subcards["+File"]
  text_card = subcards["+Text"]
  ( file_card && (file_card.stringify_keys.has_key?("file") || file_card.stringify_keys.has_key?("remote_file_url"))) || 
  ( text_card && ( text_card_content = (text_card.stringify_keys)["content"] ) && !text_card_content.empty? )
end

event :process_source_url, :before=>:process_subcards, :on=>:create, :when=>proc{  |c| !c.has_file_or_text? } do

  linkparams = subcards["+#{ Card[:wikirate_link].name }"]
  url = linkparams && linkparams[:content] or errors.add(:link, " does not exist.")
  if errors.empty? and url.length != 0
    if Card::Env.params[:sourcebox] == 'true'
      wikirate_url = "#{ Card::Env[:protocol] }#{ Card::Env[:host] }"
      if url.start_with?wikirate_url
        # try to convert the link to source card, easier for users to add source in +source editor
        uri = URI.parse(URI.unescape(url))
        cite_card = Card[uri.path]
      else
        cite_card = Card[url]
      end
      if cite_card
        if cite_card.type_code != :source
          errors.add :source, " can only be source type or valid URL."
        else
          self.name = cite_card.name
          abort :success
        end
      elsif not (url.start_with?"http://" or url.start_with?"https://") or url.start_with?wikirate_url
        errors.add :source, " does not exist."
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
    if errors.empty?
      if file_link? url
        download_file_and_add_to_plus_file url
      else
        parse_source_page url if Card::Env.params[:sourcebox] == 'true'
      end
    end
  end

end

def download_file_and_add_to_plus_file url
  url.gsub!(/ /, '%20')  
  subcards["+File"] = {
    :remote_file_url=>url,:type_id=>Card::FileID,:content=>"dummy"
  }
  subcards.delete("+#{ Card[:wikirate_link].name }")
rescue  # if open raises errors , just treat the source as a normal source
  Rails.logger.info "Fail to get the file from link"
end

def file_link? url
  # just got the header instead of downloading the whole file
  curl_result = Curl::Easy.http_head(url)
  content_type = curl_result.head[/.*Content-Type: (.*)\r\n/,1]
  content_size = curl_result.head[/.*Content-Length: (.*)\r\n/,1].to_i
  # prevent from showing file too big while users are adding a link source
  max_size = (max = Card['*upload max']) ? max.db_content.to_i : 5

  not (content_type.start_with?"text/html" or content_type.start_with?"image/") and content_size.to_i <= max_size.megabytes
rescue
  Rails.logger.info "Fail to extract header from the #{ url }"
  false
end

def parse_source_page url
  if errors.empty?
    preview = LinkThumbnailer.generate url
    if preview.images.length > 0
     subcards["+image url" ] = preview.images.first.src.to_s
    end
    subcards["+title"      ] ||= preview.title unless subcards["+Title"]
    subcards["+description"] ||= preview.description unless subcards["+Description"]
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
    if file_card and mime_type = file_card.file.content_type and ( mime_type == "text/csv" || mime_type == "text/comma-separated-values" )
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

