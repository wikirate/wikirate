include_set Abstract::WikirateTable
include_set Abstract::WikirateTabs

card_accessor :contribution_count, type: :number, default: "0"
card_accessor :direct_contribution_count, type: :number, default: "0"
card_accessor :aliases, type: :pointer
card_accessor :all_metric_values

view :missing do |args|
  _render_link args
end

format :html do
  def view_caching?
    false
  end

  view :open do |args|
    if show_contributions_profile?
      link = link_to_card card, nil, path: { about_company: true }
      output [
        (content_tag(:div, class: "contributions-about-link") do
          "showing contributions by #{link}"
        end),
        field_subformat(:contribution).render_open
      ]
    else
      super args
    end
  end
end

def add_alias alias_name
  aliases_card.insert_item! 0, alias_name
end
