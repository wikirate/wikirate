include_set Abstract::WikirateTable
include_set Abstract::Media
include_set Abstract::Export

card_accessor :contribution_count, type: :number, default: "0"
card_accessor :direct_contribution_count, type: :number, default: "0"
card_accessor :aliases, type: :pointer
card_accessor :all_metric_values
card_accessor :image
card_accessor :incorporation
card_accessor :headquarters

event :update_company_matcher, :integrate_with_delay, on: :create do
  CompanyMatcher.add_to_mapper id, name
end

def headquarters_jurisdiction_code
  (hc = headquarters_card) && (jc_card = hc.item_cards.first) &&
    jc_card.oc_code
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

