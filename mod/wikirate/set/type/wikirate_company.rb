include_set Abstract::WikirateTable
include_set Abstract::WikirateTabs

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

def add_alias alias_name
  aliases_card.insert_item! 0, alias_name
end

format :csv do
  view :core do
    Answer.where(company_id: card.id).map do |a|
      CSV.generate_line [a.metric_name, a.year, a.value]
    end.join
  end
end
