include_set Abstract::WikirateTable
include_set Abstract::Thumbnail
include_set Abstract::Media

card_accessor :vote_count, type: :number, default: "0"
card_accessor :upvote_count, type: :number, default: "0"
card_accessor :downvote_count, type: :number, default: "0"

card_accessor :image, type: :image

view :missing do
  _render_link
end

view :listing do
  _render_content structure: "browse topic item"
end

view :listing_compact do
  topic_image = card.fetch(trait: :image)
  title = link_to_card card
  text_with_image title: title, image: topic_image, size: :icon
end

def company_card
  fetch(trait: :wikirate_company, new: {})
end

def metric_card
  fetch(trait: :metric, new: {})
end
