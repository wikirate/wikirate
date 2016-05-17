card_accessor :contribution_count, type: :number, default: "0"
card_accessor :direct_contribution_count, type: :number, default: "0"

view :missing do |args|
  _render_link args
end

def indirect_contributor_search_args
  [
    { type_id: Card::ClaimID,  right_plus: ["company", { link_to: name }] },
    { type_id: Card::SourceID, right_plus: ["company", { link_to: name }] },
    { type_id: Card::WikirateAnalysisID, left: name },
    { type_id: Card::MetricValueID, left: { right: name } }
  ]
end

format :html do
  def view_caching?
    false
  end

  view :open do |args|
    if main? && !Env.ajax? && !Env.params["about_company"] &&
       !contributions_about? && contributions_made?

      link = card_link card, path_opts: { about_company: true }
      %(<div class="contributions-about-link">) \
        "showing contributions by #{link}</div>" +
        subformat(card.fetch trait: :contribution).render_open
    else
      super args
    end
  end

  def contributions_about?
    count_name =
      card.cardname.trait_name(:wikirate_topic).trait_name :cached_count
    return false unless (count = Card.fetch count_name)
    count.content.to_i > 0
  end

  view :contribution_link do
    return "" unless contributions_made?
    card_link card.cardname.trait(:contribution),
              text: "View Contributions",
              class: "btn btn-primary company-contribution-link"
  end

  def contributions_made?
    # FIXME: need way to figure this out without a search!
    Card.search(type_id: MetricID, left: card.name, return: "count") > 0
  end
end

def add_alias alias_name
  alias_card = Card.fetch "#{name}+aliases",
                          new: { type_id: Card::PointerID }
  alias_card.insert_item! 0, alias_name
end
