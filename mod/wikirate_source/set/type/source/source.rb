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
  elsif source_cards.empty?
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
  return if errors.present? || url.empty?
  if Card::Env.params[:sourcebox] == 'true'
    cite_card = get_card(url)
    if cite_card
      if cite_card.type_code != :source
        errors.add :source, 'can only be source type or valid URL.'
      else
        self.name = cite_card.name
        abort :success
      end
    elsif !url?(url) || wikirate_url?(url)
      errors.add :source, 'does not exist.'
    end
    duplicates = Self::Source.find_duplicates url
    if duplicates.any?
      duplicated_name = duplicates.first.cardname.left
      if Card::Env.params[:sourcebox] == 'true'
        self.name = duplicated_name
      else
        self.name = cite_card.name
      end
      abort :success
    elsif !url?(url) || wikirate_url?(url)
      errors.add :source, 'does not exist.'
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
  elsif Card::Env.params[:sourcebox] == 'true'
    parse_source_page url
  end
end

def url? url
  url.start_with?('http://', 'https://')
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

  !content_type.start_with?('text/html', 'image/') &&
    content_size.to_i <= max_size.megabytes
rescue
  Rails.logger.info "Fail to extract header from the #{url}"
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

# event :source_present, :validate, on: :create,
#       when: { Env.params[:preview] } do
#   if ...
#     errors.add :source, ''
#   end
# end

format :html do
  view :new do |args|
    # return super(args)
    if Env.params[:preview]
      form_opts = args[:form_opts] ? args.delete(:form_opts) : {}
      form_opts.merge! hidden: args.delete(:hidden),
                       'main-success' => 'REDIRECT',
                       'data-form-for' => 'new_metric_value',
                       class: 'card-slot new-view TYPE-source'
      card_form :create, form_opts do
        output [
          _optional_render(:name_formgroup, args),
          _optional_render(:type_formgroup, args),
          _optional_render(:content_formgroup, args),
          _optional_render(:button_formgroup, args)
        ]
      end
    else
      super(args)
    end
  end

  def default_new_args args
    if Env.params[:preview]
      args[:structure] = 'metric value source form'
      args[:buttons] =
        content_tag :button, 'Add', class: 'btn btn-primary pull-right',
                                    data: { disable_with: 'Adding' }
      args[:hidden] = {
        :success => { id: '_self', soft_redirect: true, view: :source_item },
        'card[subcards][+company][content]' => args[:company]
      }
    end
    super(args)
  end

  view :source_item do |args|
    source = render_content structure: 'source_with_preview'
    wrap_with :div, class: 'source-details',
                    data: { source_for: card.name } do
      url_card = card.fetch(trait: :wikirate_link)
      url = url_card ? url_card.item_names.first : nil
      args[:url] = url
      source + render_iframe_view(args.merge(url: url)).html_safe +
        render_hidden_information(args.merge(url: url)).html_safe
    end
  end

  view :cited do
    source = render_content structure: 'source without note count'
    # cite_button =
    #   content_tag(:a, 'cited!', class: 'btn btn-default _cited_button')
    # source << content_tag(:div, cite_button, class: 'pull-right')
    source =
      content_tag(:div, source, class: 'source-info-container with-vote-button')
    wrap_with :div, class: 'source-details-toggle',
                    data: { source_for: card.name } do
      source.html_safe
    end
  end

  def edit_slot args
    # see claim.rb for explanation of core_edit
    super args.merge(core_edit: true)
  end

  view :metric_import_link do |_args|
    file_card = Card[card.name + '+File']
    return '' unless has_import_mime_type?(file_card)
    card_link file_card, text: 'Import to metric values',
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

  view :creator_credit do |args|
    "added #{_render_created_at(args)} ago by " \
    "#{nest Card.fetch(card.cardname.field('*creator')),
            view: :core,
            item: :link}"
  end

  view :website_link do |_args|
    card_link(
      card,
      text: nest(Card.fetch(card.cardname.field('website'),
                            new: {}),
                 view: :content,
                 item: :name),
      class: 'source-preview-link',
      target: '_blank'
    )
  end

  view :title_link do |_args|
    card_link(
      card,
      text: nest(Card.fetch(card.cardname.field('title'),
                            new: {}), view: :needed),
      class: 'source-preview-link preview-page-link',
      target: '_blank'
    )
  end

  view :source_link do |_args|
    [
      content_tag(:span, _render_website_link, class: 'source-website'),
      content_tag(:i, '', class: 'fa fa-long-arrow-right'),
      content_tag(:span, _render_title_link, class: 'source-title')
    ].join "\n"
  end

  # view :cited do |args|
  #   <<-HTML
  #   <div class="source-info-container">
  #   <div class="item-content">
  #    <div class="fa fa-times-circle remove-source" style="display:none"></div>
  #    <div class="source-icon fa fa-globe"></div>
  #    <div class="item-summary">
  #     #{_render_source_link args}
  #     <div class="last-edit">
  #       #{ _render_creator_credit args
  #       }
  #     </div>
  #   </div>
  #   </div>
  # </div>
  #   HTML
  # end
end
