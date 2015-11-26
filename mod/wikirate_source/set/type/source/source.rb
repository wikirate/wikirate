require 'curb'
card_accessor :vote_count, type: :number, default: '0'
card_accessor :upvote_count, type: :number, default: '0'
card_accessor :downvote_count, type: :number, default: '0'
card_accessor :direct_contribution_count, type: :number, default: '0'
card_accessor :contribution_count, type: :number, default: '0'

card_accessor :metric, type: :pointer
card_accessor :year, type: :pointer

def indirect_contributor_search_args
  [
    { right_id: VoteCountID, left: self.name }
  ]
end

require 'link_thumbnailer'

event :vote_on_create_source,
      on: :create, after: :store,
      when: proc { Card::Auth.current_id != Card::WagnBotID } do
  Auth.as_bot do
    vc = vote_count_card
    vc.supercard = self
    vc.vote_up
    vc.save!
  end
end

event :check_source, after: :approve_subcards, on: :create do
  source_cards = [subfield(:wikirate_link),
                  subfield(:file),
                  subfield(:text)].compact
  if source_cards.length > 1
    errors.add :source, 'Please only add one type of source'
  elsif source_cards.length == 0
    errors.add :source, 'Please at least add one type of source'
  end
end

def has_file_or_text?
  file_card = subfield(:file)
  text_card = subfield(:text)
  (file_card && file_card.attachment.present?) ||
    (text_card && text_card.content.present?)
end

event :process_source_url,
      before: :process_subcards, on: :create,
      when: proc { |c| !c.has_file_or_text? } do
  linkparams = subfield(Card[:wikirate_link].name)
  url = (linkparams && linkparams.content) ||
        errors.add(:link, 'does not exist.')
  if errors.empty? && url.length != 0
    if Card::Env.params[:sourcebox] == 'true'
      cite_card = get_card(url)
      if cite_card
        if cite_card.type_code != :source
          errors.add :source, ' can only be source type or valid URL.'
        else
          self.name = cite_card.name
          abort :success
        end
      elsif !url?(url) || wikirate_url?(url)
        errors.add :source, ' does not exist.'
      end
    end
    duplicates = Self::Source.find_duplicates url
    if duplicates.any?
      duplicated_name = duplicates.first.cardname.left
      if Card::Env.params[:sourcebox] == 'true'
        self.name = duplicated_name
        abort :success
      else
        errors.add :link, "exists already. <a href=\"/#{duplicated_name}\">" \
                          'Visit the source.</a>'
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

def url? url
  url.start_with?('http://') || url.start_with?('https://')
end

def wikirate_url? url
  wikirate_url = "#{Card::Env[:protocol]}#{Card::Env[:host]}"
  url.start_with?(wikirate_url)
end

def get_card url
  if wikirate_url?(url)
    # try to convert the link to source card,
    # easier for users to add source in +source editor
    uri = URI.parse(URI.unescape(url))
    Card[uri.path]
  else
    Card[url]
  end
end

def download_file_and_add_to_plus_file url
  url.gsub!(/ /, '%20')
  add_subcard '+file', remote_file_url: url, type_id: FileID, content: 'dummy'
  remove_subfield Card[:wikirate_link].name
rescue  # if open raises errors , just treat the source as a normal source
  Rails.logger.info 'Fail to get the file from link'
end

def file_link? url
  # just got the header instead of downloading the whole file
  curl = Curl::Easy.new(url)
  curl.follow_location = true
  curl.max_redirects = 5
  curl.http_head
  content_type = curl.head[/.*Content-Type: (.*)\r\n/, 1]
  content_size = curl.head[/.*Content-Length: (.*)\r\n/, 1].to_i
  # prevent from showing file too big while users are adding a link source
  max_size = (max = Card['*upload max']) ? max.db_content.to_i : 5

  !(content_type.start_with?('text/html') ||
    content_type.start_with?('image/')) &&
    content_size.to_i <= max_size.megabytes
rescue
  Rails.logger.info "Fail to extract header from the #{ url }"
  false
end

def parse_source_page url
  return if errors.present?
  preview = LinkThumbnailer.generate url
  if preview.images.length > 0
    add_subcard '+image url', content: preview.images.first.src.to_s
  end
  unless subfield('title')
    add_subcard '+title', content: preview.title
  end
  unless subfield('Description')
    add_subcard '+description', content: preview.description
  end
rescue
  Rails.logger.info "Fail to extract information from the #{ url }"
end

event :autopopulate_website, after: :approve_subcards, on: :create do
  website = Card[:wikirate_website].name
  if (link_card = subfield(:wikirate_link)) && link_card.errors.empty?
    website_subcard = subfield(website)
    unless website_subcard
      host = link_card.instance_variable_get '@host'
      website_card = Card.new name: "+#{website}",
                              content: "[[#{host}]]",
                              supercard: self
      website_card.approve
      # subcards["+#{website}"] = website_card
      add_subcard "+#{website}", website_card
      if !Card.exists? host
        Card.create name: host, type_id: Card::WikirateWebsiteID
      end
    end
  end
  if subfield('File')
    unless website_subcard
      website_card = Card.new name: "+#{website}",
                              content: '[[wikirate.org]]',
                              supercard: self
      website_card.approve
      add_subcard "+#{website}", website_card
    end
  end
end

format :html do
  def edit_slot args
    # see claim.rb for explanation of core_edit
    super args.merge(core_edit: true)
  end

  view :metric_import_link do |args|
    file_card = Card[card.name+'+File']
    return '' unless has_import_mime_type?(file_card)
    card_link file_card, text: "Import to metric values",
                         path_opts: { view: :import }
  end

  def has_import_mime_type? file_card
    file_card && (mime_type = file_card.file.content_type) &&
      (mime_type == 'text/csv' || mime_type == 'text/comma-separated-values')
  end

  view :original_link do |args|
    with_original do |card, type|
      case type
      when :file
        link_to (args[:title] || 'Download'),card.file.url
      when :link
        link_to (args[:title] || 'Visit Source'),card.content
      when :text
        card_link card, text: (args[:title] || 'Visit Text Source')
      end
    end
  end

  view :original_icon_link do |args|
    title = content_tag(:i, '', class: "fa fa-#{icon}")
    _render_original_link args.merge(title: title)
  end

  def with_original
    if file_card = card.fetch(trait: :file )
      yield file_card, :file
    elsif link_card = card.fetch(trait: :wikirate_link)
      yield link_card, :link
    elsif text_card = card.fetch(trait: :text)
      yield text_card, :text
    end
  end

  def icon
    case source_type
    when :file
      'upload'
    when :link
      'globe'
    when :text
      'pencil'
    end
  end

  def source_type
    if card.fetch trait: :file
      :file
    elsif card.fetch(trait: :wikirate_link)
      :link
    elsif card.fetch(trait: :text)
      :text
    end
  end

  view :content do |args|
    add_name_context
    super args
  end

  view :missing do |args|
    _view_link args
  end

  view :titled, tags: :comment do |args|
    render_titled_with_voting args
  end

  view :open do |args|
    super args.merge(custom_source_header: true)
  end

  view :header do |args|
    if args.delete(:custom_source_header)
      render_header_with_voting
    else
      super(args)
    end
  end
end
