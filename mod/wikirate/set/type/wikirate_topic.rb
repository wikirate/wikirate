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

view :listing do
  _render_content structure: "browse topic item"
end

# def related_company_from_source_or_note
#   Card.search(type_id: Card::WikirateCompanyID,
#               referred_to_by: {
#                 left: {
#                   type: %w(in Note Source),
#                   right_plus: ["topic", refer_to: name]
#                 },
#                 right: "company"
#               },
#               return: "id")
# end

def companies_related_by_metric
  metric_ids =
    Card.search right_plus: [Card::WikirateTopicID, { refer_to: value }],
                return: :id
  Answer.select(:company_id).where(metric_id: metric_ids).uniq
end

def related_companies_count
  companies_related_by_metric.count
end

def related_companies
  companies_related_by_metric.all
end
