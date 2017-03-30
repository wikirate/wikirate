include_set Abstract::WikirateTable
include_set Abstract::WikirateTabs
include_set Abstract::Media

card_accessor :contribution_count, type: :number, default: "0"
card_accessor :direct_contribution_count, type: :number, default: "0"
card_accessor :aliases, type: :pointer
card_accessor :all_metric_values

view :missing do |args|
  _render_link args
end

view :listing do
  # TODO: 1. move this structure to code under "browse_item" view
  #       2. create a more appropriate listing structure
  _render_content structure: "browse company item"
end

# def subcard_count_number subcard
#   subcard_count = nest(card, trait: subcard.to_sym, view: :count)
#   content_tag(:div, subcard_count, class: "number")
# end
#
# def subcard_count_with_label subcard
#   subcard_label = nest(card, trait: subcard.to_sym, view: :name)
#   number_label = content_tag(:div, subcard_label, class: "number-label")
#   wrap_with :div, class: "count-view slab" do
#     [
#       subcard_count_number(subcard),
#       number_label
#     ]
#   end
# end

view :metric_count do
  content_tag(:div, nest(card, trait: :metric, view: :count), class: "number")
end

view :topic_count do
  content_tag(:div, nest(card, trait: :topic, view: :count), class: "number")
end

view :listing_compact do
  company_image = card.fetch(trait: :image)
  title = link_to_card card
  text_with_image title: title, image: company_image, size: :icon
end

def add_alias alias_name
  aliases_card.insert_item! 0, alias_name
end

format :csv do
  view :core do
    Answer.where(company_id: card.id).map do |a|
      a.csv_line
    end.join
  end
end
