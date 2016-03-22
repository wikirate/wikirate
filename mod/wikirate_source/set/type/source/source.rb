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
      when: proc { Card::Auth.current_id != Card::WagnBotID }do
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
      form_opts[:hidden] = args.delete(:hidden)
      form_opts['main-success'] = 'REDIRECT'
      form_opts['data-form-for'] = 'new_metric_value'
      form_opts[:class] = "card-slot"
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
      args[:buttons] = content_tag(
                              :button,
                              'Add',
                              class: 'btn btn-primary pull-right',
                              data: { disable_with: 'Adding' })
      args[:hidden] = {
        :success => { id: '_self', soft_redirect: true, view: :source_item },
        'card[subcards][+company][content]' => args[:company]
      }
    end
    super(args)
  end
  view :source_item do |args|
    # content_tag(:div,'meow',class:'h1')
    wrap_with :div, class: 'source-details', data: { source_for: card.name } do
      result = render_content structure: 'source_with_preview'
      result + render_iframe_view(args.merge(url: card.fetch(trait: :wikirate_link).content))
    end
  end

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

  view :creator_credit do |args|
    "added #{_render_created_at(args)} ago by " \
    "#{nest Card.fetch(card.cardname.field('*creator')),
        view: :core,
        item: :link
      }"
  end

  view :website_link do |args|
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

  view :title_link do |args|
    card_link(
      card,
      text: nest(Card.fetch(card.cardname.field('title'), new: {}), view: :needed),
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

  view :cited do |args|
    <<-HTML
    <div class="source-info-container">
    <div class="item-content">
     <div class="fa fa-times-circle remove-source" style="display:none"></div>
     <div class="source-icon fa fa-globe"></div>
     <div class="item-summary">
      #{_render_source_link args}
      <div class="last-edit">
        #{ _render_creator_credit args
        }
      </div>
    </div>
    </div>
  </div>
    HTML
  end
end
