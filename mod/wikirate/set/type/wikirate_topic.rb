include_set Abstract::WikirateTable
include_set Abstract::WikirateTabs
include_set Abstract::Thumbnail

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

def company_card
  fetch(trait: :wikirate_company, new: {})
end

def metric_card
  fetch(trait: :metric, new: {})
end
