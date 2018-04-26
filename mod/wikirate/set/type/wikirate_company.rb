include_set Abstract::WikirateTable
include_set Abstract::WikirateTabs
include_set Abstract::Media
include_set Abstract::Export

card_accessor :contribution_count, type: :number, default: "0"
card_accessor :direct_contribution_count, type: :number, default: "0"
card_accessor :aliases, type: :pointer
card_accessor :all_metric_values
card_accessor :image
card_accessor :incorporation
card_accessor :headquarters

def headquarters_jurisdiction_code
  (hc = headquarters_card) && (jc_card = hc.item_cards.first) &&
    jc_card.oc_code
end

view :missing do
  _render_link
end

view :listing do
  wrap_with :div, class: "border p-2" do
    _render_thumbnail_no_link
  end
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
  wrap_with(:div, nest(card, trait: :metric, view: :count), class: "number")
end

view :topic_count do
  wrap_with(:div, nest(card, trait: :topic, view: :count), class: "number")
end

view :listing_compact do
  company_image = card.fetch(trait: :image)
  title = link_to_card card
  text_with_image title: title, image: company_image, size: :icon
end

def add_alias alias_name
  aliases_card.insert_item! 0, alias_name
end

def all_answers
  Answer.where company_id: id
end

format :csv do
  view :core do
    Answer.csv_title + card.all_answers.map(&:csv_line).join
  end
end

format :html do
  view :link, closed: true, perms: :none do
    return super() unless voo.closest_live_option(:project)
    title = title_in_context voo.title
    opts = { known: card.known? }
    opts[:path] = { filter: { project: voo.closest_live_option(:project) } }
    opts[:path][:card] = { type: voo.type } if voo.type && !opts[:known]
    link_to_card card.name, title, opts
  end
end

format :json do
  view :core do
    card.all_answers.map do |answer|
      subformat(answer.card)._render_core
    end
  end
end

event :update_company_matcher, :integrate_with_delay, on: :create do
  CompanyMatcher.add_to_mapper id, name
end
