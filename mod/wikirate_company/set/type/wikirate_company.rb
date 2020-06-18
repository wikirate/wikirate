# -*- encoding : utf-8 -*-

include_set Abstract::Media
include_set Abstract::Delist
include_set Abstract::Accountable
include_set Abstract::TwoColumnLayout

include_set Abstract::Bookmarkable
# include_set Abstract::Export

card_accessor :aliases, type: PointerID
card_accessor :metric_answer
card_accessor :image
card_accessor :incorporation
card_accessor :headquarters

event :validate_company_name, :validate, changed: :name do
  errors.add :name, "Use ＋ instead of + in company name" if name.junction?
end

event :ensure_wikipedia_mapping_attempt, :validate, on: :create do
  ensure_subfield :wikipedia
end

event :delete_all_company_answers, :store, on: :delete do
  answers.delete_all
  skip_event! :reset_double_check_flag,
              :delete_answer_lookup_table_entry_due_to_value_change,
              :delete_relationship_lookup_table_entry_due_to_value_change,
              :update_related_calculations
end

# happens in optimized event below
event :skip_answer_updates_on_company_rename, :validate,
      on: :update, changed: :name do
  skip_event! :update_answer_lookup_table_due_to_answer_change
end

event :refresh_renamed_company_answers, :finalize,
      on: :update, changed: :name do
  refresh_name_in_lookup_table
end

def refresh_name_in_lookup_table
  answers.where.not(company_name: name).update_all company_name: name
  answers.each { |a| a.refresh :record_name }
  # FIXME: the above is one argument for getting rid of record_name.  Too slow!
end

def headquarters_jurisdiction_code
  headquarters_card&.item_cards&.first&.oc_code
end

def add_alias alias_name
  aliases_card.insert_item! 0, alias_name
end

# @return [Answer]
def latest_answer metric
  answers(metric: metric, latest: true).first
end

# @return [Answer::ActiveRecord_Relation]
def answers args={}
  args[:company_id] = id
  normalize_metric_arg args
  Answer.where args
end

# @return [Relationship::ActiveRecord_Relation]
def relationships args={}
  args[:subject_company_id] = id
  normalize_metric_arg args
  Relationship.where args
end

# @return [Relationship::ActiveRecord_Relation]
def inverse_relationships args={}
  args[:object_company_id] = id
  normalize_metric_arg args
  Relationship.where args
end

# @return [Array] of Cards
def related_companies args={}
  prefix = args.delete(:inverse) ? "inverse_" : ""
  method = "#{prefix}related_company_ids"
  send(method, args).map { |company_id| Card[company_id] }
end

# @return [Array] of Integers
def related_company_ids args={}
  relationships(args).distinct.pluck :object_company_id
end

def related_company_names args={}
  relationships(args).distinct.pluck :object_company_name
end

# @return [Array] of Integers
def inverse_related_company_ids args={}
  inverse_relationships(args).distinct.pluck :subject_company_id
end

private

def normalize_metric_arg args={}
  return unless (metric = args.delete :metric)

  args[:metric_id] = Card.fetch_id metric
end

# DEPRECATED.  +answer csv replaces following:
format :csv do
  view :core do
    Answer.csv_title + card.answers.map(&:csv_line).join
  end
end
