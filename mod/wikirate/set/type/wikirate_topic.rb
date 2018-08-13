include_set Abstract::WikirateTable
include_set Abstract::Thumbnail
include_set Abstract::Media
include_set Abstract::BsBadge

card_accessor :vote_count, type: :number, default: "0"
card_accessor :upvote_count, type: :number, default: "0"
card_accessor :downvote_count, type: :number, default: "0"

card_accessor :image, type: :image

view :missing do
  _render_link
end

view :bar do
  render :bar_compact
end

view :bar_compact do
  topic_image = card.fetch(trait: :image)
  title = link_to_card card
  text_with_image title: title, image: topic_image, size: :icon
end

# def image_card
#   card.fetch(trait: :image)
# end

view :box_middle do
  nest(image_card, view: :core, size: :medium)
end

view :box_bottom, template: :haml do
  @company_badge = labeled_badge company_card.cached_count, "Companies", color: "company"
  @metric_badge = labeled_badge metric_card.cached_count, "Metrics", color: "metric"
end

def company_card
  fetch(trait: :wikirate_company, new: {})
end

def metric_card
  fetch(trait: :metric, new: {})
end
