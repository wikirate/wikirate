require "curb"
card_accessor :vote_count, type: :number, default: "0"
card_accessor :upvote_count, type: :number, default: "0"
card_accessor :downvote_count, type: :number, default: "0"
card_accessor :direct_contribution_count, type: :number, default: "0"
card_accessor :contribution_count, type: :number, default: "0"

card_accessor :metric, type: :pointer
card_accessor :year, type: :pointer
card_accessor :source_type, type: :pointer, default: "[[Link]]"

def indirect_contributor_search_args
  [
    { right_id: VoteCountID, left: name }
  ]
end

require "link_thumbnailer"

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
    errors.add :source, "Only one type of content is allowed"
  elsif source_cards.empty?
    errors.add :source, "Source content required"
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
      form_opts.merge! hidden: args.delete(:hidden),
                       "main-success" => "REDIRECT",
                       "data-form-for" => "new_metric_value",
                       class: "card-slot new-view TYPE-source"
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
      args[:structure] = "metric value source form"
      args[:buttons] =
        content_tag :button, "Add and preview",
                    class: "btn btn-primary pull-right",
                    data: { disable_with: "Adding" }
      args[:hidden] = {
        :success => { id: "_self",
                      soft_redirect: true,
                      view: :source_and_preview },
        "card[subcards][+company][content]" => args[:company]
      }
    end
    super(args)
  end

  # show link if link source
  view :source_item do |_args|
    original_link = ""
    if card.source_type_codename == :wikirate_link
      link = card.fetch(trait: :wikirate_link).content
      original_link =
        <<-HTML
          <a class="view-original-url" href="#{link}" target="_blank">
            <i class="fa fa-external-link-square cursor"></i>
            Original
          </a>
        HTML
    end
    unless year.nil? || year == ""
      year_helper =
        content_tag(:small, "year:" + year[/\d+/], class: "source-year")
      original_link << year_helper.html_safe
    end
    original_link + render_content(structure: "source_without_note_count")
  end

  view :with_cite_button do |_args|
    cite_button =
      content_tag(:div, "Cite!", class: "btn btn-highlight _cite_button")
    content =
      _render_source_item +
      content_tag(:div, cite_button, class: "pull-right")
    wrap_with_info content
  end

  view :source_and_preview do |args|
    wrap_with :div, class: "source-details",
                    data: { source_for: card.name, year: year } do
      url_card = card.fetch(trait: :wikirate_link)
      url = url_card ? url_card.item_names.first : nil
      args[:url] = url
      render_with_cite_button +
        render_iframe_view(args.merge(url: url)).html_safe +
        render_hidden_information(args.merge(url: url)).html_safe
    end
  end

  view :relevant do |_args|
    add_toggle render_with_cite_button.html_safe
  end

  view :cited do
    source = wrap_with_info _render_source_item
    add_toggle(source)
  end

  def year
    return card.fetch(trait: :year).content if card.fetch(trait: :year)
    ""
  end

  def wrap_with_info content
    wrap do
      content_tag(:div, content.html_safe,
                  class: "source-info-container with-vote-button")
    end
  end

  def add_toggle content
    wrap_with :div, class: "source-details-toggle",
                    data: { source_for: card.name, year: year } do
      content.html_safe
    end
  end

  def edit_slot args
    # see claim.rb for explanation of core_edit
    super args.merge(core_edit: true)
  end

  view :metric_import_link do |_args|
    ""
  end

  view :original_icon_link do |args|
    _render_original_link args.merge(title: content_tag(:i, "",
                                                        class: "fa fa-#{icon}"))
  end

  def icon
    # default as link
    "globe"
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
    content_tag(:div, creator(args).html_safe, class: "last-edit")
  end

  def creator args
    "added #{_render_created_at(args)} ago by " \
    "#{nest Card.fetch(card.cardname.field('*creator')),
            view: :core,
            item: :link}"
  end

  view :website_link do |_args|
    card_link(
      card,
      text: nest(Card.fetch(card.cardname.field("website"), new: {}),
                 view: :content,
                 item: :name),
      class: "source-preview-link",
      target: "_blank"
    )
  end

  view :title_link do |_args|
    card_link(
      card,
      text: nest(Card.fetch(card.cardname.field("title"), new: {}),
                 view: :needed),
      class: "source-preview-link preview-page-link",
      target: "_blank"
    )
  end

  view :source_link do |_args|
    [
      content_tag(:span, _render_website_link, class: "source-website"),
      content_tag(:i, "", class: "fa fa-long-arrow-right"),
      content_tag(:span, _render_title_link, class: "source-title")
    ].join "\n"
  end

  view :vote do |args|
    subformat(Card["#{card.name}+*vote count"]).render_content args
  end

  view :icon do
    icon = content_tag(:i, "", class: "fa fa-globe")
    content_tag(:div, icon, class: "source-icon")
  end

  view :note_count do
    note_count = nest(Card.fetch("#{card.name}+Note Count"), view: :core)
    <<-HTML
    <a href='/#{card.name}+source note list' class="show-link-in-popup">
      <span class="note-count">
      #{note_count}
      </span>
      <span class="note-count">
       Notes
      </span>
    </a>
    HTML
  end

  view :source_list_item do
    wrap_with :div, class: "item-content" do
      [
        _render_vote,
        _render_icon,
        _render_source_link,
        _render_creator_credit,
        _render_note_count
      ]
    end
  end
end
