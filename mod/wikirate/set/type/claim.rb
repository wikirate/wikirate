# changes label of name on claims (should be obviatable)

card_accessor :vote_count, type: :number, default: "0"
card_accessor :upvote_count, type: :number, default: "0"
card_accessor :downvote_count, type: :number, default: "0"
card_accessor :direct_contribution_count, type: :number, default: "0"
card_accessor :contribution_count, type: :number, default: "0"

def indirect_contributor_search_args
  [{ right_id: VoteCountID, left: name }]
end

# has to happen before the contributions update (the new_contributions event)
# so we have to use the finalize stage
event :vote_on_create_claim, :integrate,
      on: :create,
      when: proc { Card::Auth.current_id != Card::WagnBotID } do
  Auth.as_bot do
    vc = vote_count_card
    vc.vote_up
    vc.supercard = self
    vc.save!
  end
end

format :html do
  view :name_formgroup do |_args|
    # rename 'name' to 'Claim'
    # add a div for claim word counting
    %{
      <div class='row'>
        <div class='col-md-12'>
          #{formgroup 'Note', raw(name_field form), editor: 'name', help: true}
          <div class='note-counting'>
            <span class='note-counting-number'>100</span> character(s) left
          </div>
        </div>
      </div>
    }
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
    args[:citation_number] || optional_render(:cite_button, args)
  end

  view :cite_button do |_args|
    if parent.parent.present? && parent.parent.card.present?
      article_name = parent.parent.card.cardname.url_key
      url =
        "/#{article_name}?citable=#{card.cardname.url_key}&edit_article=true"
      link_to "Cite!", url, class: "cite-button"
    else
      ""
    end
  end

  view :new do |args|
    # hide all help text under title
    super args.merge(optional_help: :hide)
  end

  def edit_slot args
    # :core_edit means the new and edit views will render form fields from
    # within the core view (which in this case is defined by
    # Claim+*type+*structure), as opposed to the default behavior,
    # which is to strip out the nests and render them alone.
    super args.merge(core_edit: true)
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
    if !topics = Card["#{card.name}+topics"] ||
                 topics.item_names.empty?
      "improve this note by adding a topic."
    elsif !companies = Card["#{card.name}+company"] ||
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

  view :sample_citation do |_args|
    tip = "easily cite this note by pasting the following:" +
          text_area_tag(:citable_note, card.default_citation)
    %( <div class="sample-citation">#{render :tip, tip: tip}</div> )
  end

  view :titled, tags: :comment do |args|
    render_titled_with_voting args
  end

  view :open do |args|
    super args.merge(custom_claim_header: true, optional_horizontal_menu: :hide)
  end

  view :header do |args|
    if args[:custom_claim_header]
      render_haml(args: args) do
        %{
.header-with-vote
  .header-vote
    = subformat(card.vote_count_card).render_details
  .header-citation
    = nest card.fetch(trait: :citation_count), view: :titled, hide: 'menu', title: 'Citations'
  .header-title
    %h1.card-header
      = _optional_render :toggle, args, :hide
      %i.fa.fa-quote-left
      = _optional_render :title, args
      %i.fa.fa-quote-right
    .creator-credit
      = nest card, structure: 'creator credit'
.clear-line
        }
      end
    else
      super(args)
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

event :reset_claim_counts, :integrate do
  Card.reset_claim_counts
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

view :clipboard do |_args|
  %(
    <i class="fa fa-clipboard claim-clipboard" id="copy-button" title="copy claim citation to clipboard" data-clipboard-text="#{h card.default_citation}"></i>
  )
end

def default_citation
  "#{name} {{#{name}|cite}}"
end
