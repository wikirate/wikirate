require 'curb'
card_accessor :vote_count, type: :number, default: '0'
card_accessor :upvote_count, type: :number, default: '0'
card_accessor :downvote_count, type: :number, default: '0'
card_accessor :direct_contribution_count, type: :number, default: '0'
card_accessor :contribution_count, type: :number, default: '0'

card_accessor :metric, type: :pointer
card_accessor :year, type: :pointer
card_accessor :source_type, type: :pointer, default: '[[Link]]'

def indirect_contributor_search_args
  [
    { right_id: VoteCountID, left: name }
  ]
end

require 'link_thumbnailer'

# has to happen before the contributions update (the new_contributions event)
# so we have to use the finalize stage
event :vote_on_create_source, :integrate,
      on: :create,
      when: proc { Card::Auth.current_id != Card::WagnBotID } do
  Auth.as_bot do
    vc = vote_count_card
    vc.supercard = self
    vc.vote_up
    vc.save!
  end
end

event :check_source, :validate, on: :create do
  source_cards = [subfield(:wikirate_link),
                  subfield(:file),
                  subfield(:text)].compact
  if source_cards.length > 1
    errors.add :source, 'Only one type of content is allowed'
  elsif source_cards.length == 0
    errors.add :source, 'Source content required'
  end
end

def attached_file_exist? file_card
  file_card.attachment.present? ||
    (file_card.save_preliminary_upload? &&
     file_card.action_id_of_cached_upload.present?
    )
end

def has_file_or_text?
  file_card = subfield(:file)
  text_card = subfield(:text)
  (file_card && attached_file_exist?(file_card)) ||
    (text_card && text_card.content.present?)
end

event :process_source_url, :prepare_to_validate,
      on: :create, when: proc { |c| !c.has_file_or_text? } do
  linkparams = subfield(Card[:wikirate_link].name)
  url = (linkparams && linkparams.content) ||
        errors.add(:link, 'does not exist.')
  return if errors.present? || url.length == 0
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
      errors.add :source, " does not exist."
    end
    duplicates = Self::Source.find_duplicates url
    if duplicates.any?
      duplicated_name = duplicates.first.cardname.left
      if Card::Env.params[:sourcebox] == 'true'
        self.name = duplicated_name
        abort :success
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
  return if errors.present?
  if file_link? url
    download_file_and_add_to_plus_file url
  else
    parse_source_page url if Card::Env.params[:sourcebox] == 'true'
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

def source_type_codename
  source_type_card.item_cards[0].codename.to_sym
end

def analysis_names
  return [] unless (topics = fetch(trait: :wikirate_topic)) &&
                   (companies = fetch(trait: :wikirate_company))
  companies.item_names.map do |company|
    topics.item_names.map do |topic|
      "#{company}+#{topic}"
    end
  end.flatten
end

def analysis_cards
  analysis_names.map { |aname| Card.fetch aname }
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

  view :metric_import_link do |_args|
    ''
  end

  view :original_icon_link do |args|
    _render_original_link args.merge(title: content_tag(:i, '',
                                                        class: "fa fa-#{icon}"))
  end

  def icon
    # default as link
    'globe'
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
