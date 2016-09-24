card_accessor :contribution_count, type: :number, default: "0"
card_accessor :direct_contribution_count, type: :number, default: "0"
card_accessor :aliases, type: :pointer
card_accessor :all_metric_values

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

      link = link_to_card card, nil, path: { about_company: true }
      %(<div class="contributions-about-link">) \
        "showing contributions by #{link}</div>" +
        subformat(card.fetch(trait: :contribution)).render_open
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
    link_to_card card.cardname.trait(:contribution), "View Contributions",
                 class: "btn btn-primary company-contribution-link"
  end

  def contributions_made?
    # FIXME: need way to figure this out without a search!
    Card.search(type_id: MetricID, left: card.name, return: "count") > 0
  end

  view :metric_tab do |args|
    wrap do
      [
        _render_filter(args),
        _render_metric_list(args)
      ]
    end
  end

  view :filter do |args|
    field_subformat(:company_metric_filter)._render_core args
  end

  view :metric_list do
    wrap_with :div, class: "yinyang-list" do
      subformat(card, :all_metric_values)
        ._render_content(hide: "title",
                         items: { view: :metric_row })
    end
  end
end

def add_alias alias_name
  aliases_card.insert_item! 0, alias_name
end
