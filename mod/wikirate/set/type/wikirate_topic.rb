include_set Abstract::WikirateTable
include_set Abstract::WikirateTabs

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

