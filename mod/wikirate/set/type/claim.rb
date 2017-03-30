# changes label of name on claims (should be obviatable)

card_accessor :vote_count, type: :number, default: "0"
card_accessor :upvote_count, type: :number, default: "0"
card_accessor :downvote_count, type: :number, default: "0"
card_accessor :direct_contribution_count, type: :number, default: "0"
card_accessor :contribution_count, type: :number, default: "0"

# has to happen before the contributions update (the new_contributions event)
# so we have to use the finalize stage
event :vote_on_create_claim, :integrate, on: :create, when: :not_bot? do
  Auth.as_bot do
    vc = vote_count_card
    vc.vote_up
    vc.supercard = self
    vc.save!
  end
end

def not_bot?
  Card::Auth.current_id != Card::WagnBotID
end

format :html do
  view :name_formgroup do
    voo.show! :help

    # rename 'name' to 'Claim'
    # add a div for claim word counting
    wrap_with :div, class: "row" do
      wrap_with :div, class: "col-md-12" do
        [formgroup("Note", editor: "name", help: true) { name_field },
         _optional_render_note_counting]
      end
    end
  end

  view :note_counting do
    wrap_with :div, class: "note-counting" do
      [wrap_with(:span, "100", class: "note-counting-number"),
       " character(s) left"]
    end
  end

  view :citation_and_content do |args|
    output([
             render_citation_or_cite_button(args),
             render_content(args)
           ])
  end

  view :citation_or_clipboard do |args|
    args[:citation_number] || optional_render(:clipboard, args)
  end

  view :citation_or_cite_button do |args|
    args[:citation_number] || optional_render(:cite_button)
  end

  view :listing do
    _render_content structure: "note item"
  end

  view :cite_button do
    article_format = parent.parent
    return "" unless article_format && (article_card = article_format.card)
    link_to_card article_card, "Cite!",
                 path: { citable: card.cardname, edit_article: true },
                 class: "cite-button"
  end

  view :new do
    # hide all help text under title
    voo.hide :help
    super()
  end

  def edit_slot
    voo.editor = :inline_nests
    super
  end

  view :tip, perms: :none, closed: :blank do |args|
    # special view for prompting users with next steps
    if Auth.signed_in? &&
       (tip = args[:tip] || next_step_tip) &&
       @mode != :closed
      %(
        <div class="note-tip">
          Tip: You can #{tip}
          <span id="close-tip" class="fa fa-times-circle"></span>
        </div>
      )
    end.to_s
  end

  def next_step_tip
    # FIXME: cardnames
    if !(topics = card.fetch(trait: :wikirate_topic)) ||
       topics.item_names.empty?
      "improve this note by adding a topic."
    elsif !(companies = card.fetch(trait: :wikirate_company)) ||
          companies.item_names.empty?
      "improve this note by adding a company."
    else
      cited_in = Card.search refer_to: card.name,
                             left: { type_id: WikirateAnalysisID },
                             right: { name: Card[:overview].name }
      if card.analysis_names.size > cited_in.size
        "cite this note in related overviews."
      end
    end
  end

  view :sample_citation do
    tip = "easily cite this note by pasting the following:" +
          text_area_tag(:citable_note, card.default_citation)
    %( <div class="sample-citation">#{render :tip, tip: tip}</div> )
  end

  view :open do
    voo.hide :horizontal_menu
    voo.show :claim_header
    super()
  end

  view :titled, tags: :comment do
    render_titled_with_voting
  end

  view :header do
    voo.viz_hash[:claim_header] == :show ? _render_claim_header : super()
  end

  view :claim_header do
    voo.hide :toggle
    render_haml cite_count_card: card.fetch(trait: :citation_count) do
      %{
.header-with-vote
  .header-vote
    = subformat(card.vote_count_card).render_details
  .header-citation
    = nest cite_count_card, view: :titled, hide: 'menu', title: 'Citations'
  .header-title
    %h1.card-header
      = _optional_render :toggle
      %i.fa.fa-quote-left
      = _optional_render :title
      %i.fa.fa-quote-right
    .creator-credit
      = nest card, structure: 'creator credit'
.clear-line
      }
    end
  end
end

def analysis_names
  return [] unless (topics = Card["#{name}+#{Card[:wikirate_topic].name}"]) &&
                   (companies = Card["#{name}+#{Card[:wikirate_company].name}"])

  companies.item_names.map do |company|
    topics.item_names.map do |topic|
      "#{company}+#{topic}"
    end
  end.flatten
end

def analysis_cards
  analysis_names.map { |aname| Card.fetch aname }
end

# TODO: check if this can be moved to :validate stage
# (was in before: :approve)
event :validate_note, :prepare_to_validate, on: :save do
  errors.add :note, "is too long (100 character maximum)" if name.length > 100
end

event :validate_source, :validate, on: :save do
  # 1. it correctly validates when adding a claim
  # 2. it correctly validates when editing a claim with +source
  # 3. it doesn't break anything when editing a claim without +source
  #    (eg renaming)

  # first, get the source card from request
  source_card = subcards["+source"] || subcards["+Source"]
  return unless source_card || new_card?
  check_source source_card
end

def check_source source_card
  if !source_card || !source_card.content.present?
    errors.add :source, "is empty"
  else
    source_card.item_cards.each do |item_card|
      if !item_card.real?
        errors.add :source, "#{item_card.name} does not exist"
      elsif item_card.type_id != Card::SourceID
        errors.add :source, "#{item_card.name} is not a valid Source Page"
      end
    end
  end
end

view :missing do |args|
  _render_link args
end

view :clipboard do
  wrap_with :i, "", class: "fa fa-clipboard claim-clipboard",
                    id: "copy-button",
                    title: "copy claim citation to clipboard",
                    "data-clipboard-text" => h(card.default_citation)
end

def default_citation
  "#{name} {{#{name}|cite}}"
end
