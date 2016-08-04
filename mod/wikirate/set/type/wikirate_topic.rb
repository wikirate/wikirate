card_accessor :vote_count, type: :number, default: "0"
card_accessor :upvote_count, type: :number, default: "0"
card_accessor :downvote_count, type: :number, default: "0"

card_accessor :contribution_count, type: :number, default: "0"
card_accessor :direct_contribution_count, type: :number, default: "0"

view :missing do |args|
  _render_link args
end

def indirect_contributor_search_args
  [
    { type_id: Card::ClaimID, right_plus: ["topic", link_to: name] },
    { type_id: Card::SourceID, right_plus: ["topic", link_to: name] },
    { type_id: Card::WikirateAnalysisID, right: name }
  ]
end

def related_company_from_source_or_note
  Card.search(type_id: Card::WikirateCompanyID,
              referred_to_by: {
                left: {
                  type: %w(in Note Source),
                  right_plus: ["topic", refer_to: name]
                },
                right: "company"
              },
              return: "id")
end

def related_company_from_metric
  Card.search type_id: Card::WikirateCompanyID,
              left_plus: [
                {
                  type_id: Card::MetricID,
                  right_plus: ["topic", { refer_to: name }]
                },
                {
                  right_plus: ["*cached_count", { content: %w(ne 0) }]
                }
              ],
              return: :id
end

def related_companies
  (related_company_from_source_or_note + related_company_from_metric).uniq
end

format :html do
  def view_caching?
    true
  end
  view :metric_tab do |args|
    wrap do
      [
        _render_filter(args),
        _render_metric_list(args)
      ]
    end
  end

  view :company_tab do |args|
    wrap do
      [
        _render_company_filter(args),
        _render_company_list(args)
      ]
    end
  end

  view :company_filter do |args|
    field_subformat(:topic_company_filter)._render_core args
  end

  view :company_list do
    wrap_with :div, class: "yinyang-list" do
      subformat("#{card.name}+all company")
        ._render_content(hide: "title",
                         items: { view: :topic_company_row })
    end
  end

  view :filter do |args|
    field_subformat(:topic_metric_filter)._render_core args
  end

  view :metric_list do
    wrap_with :div, class: "yinyang-list" do
      subformat("#{card.name}+all metric")
        ._render_content(hide: "title",
                         items: { view: :metric_row })
    end
  end
end
