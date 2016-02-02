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

event :vote_on_create_source,
      on: :create, after: :store,
      when: proc { |_c| Card::Auth.current_id != Card::WagnBotID }do
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
    errors.add :source, 'Only one type of content is allowed'
  elsif source_cards.length == 0
    errors.add :source, 'Source content required'
  end
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
