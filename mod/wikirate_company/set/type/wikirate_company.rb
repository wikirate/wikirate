# -*- encoding : utf-8 -*-

include_set Abstract::WikirateTable
include_set Abstract::Media
include_set Abstract::Delist
include_set Abstract::Accountable
include_set Abstract::Bookmarkable
# include_set Abstract::Export

card_accessor :aliases, type: :pointer
card_accessor :metric_answer
card_accessor :image
card_accessor :incorporation
card_accessor :headquarters

event :validate_company_name, :validate, changed: :name do
  errors.add :name, "Use ＋ instead of + in company name" if name.junction?
end

event :ensure_wikipedia_mapping_attempt, :validate, on: :create do
  if Card::Codename.exist? :wikipedia
    ensure_subfield :wikipedia
  end
end

event :update_company_matcher, :integrate_with_delay, on: :create do
  CompanyMatcher.add_to_mapper id, name
end

# note: for answers with cards, this happens via answer events,
# but calculated answers don't have cards, so this has to happen via a company
event :refresh_renamed_company_answers, :integrate,
      on: :update, changed: :name, after_subcards: true do
  all_answers.where.not(company_name: name).each do |answer|
    answer.refresh :record_name, :company_name
  end
end

def headquarters_jurisdiction_code
  headquarters_card&.item_cards&.first&.oc_code
end

def add_alias alias_name
  aliases_card.insert_item! 0, alias_name
end

# "researched" as in the status, not the metric type(s)
def all_answers
  Answer.where company_id: id
end

# DEPRECATED.  +answer csv replaces following:
format :csv do
  view :core do
    Answer.csv_title + card.all_answers.map(&:csv_line).join
  end
end
