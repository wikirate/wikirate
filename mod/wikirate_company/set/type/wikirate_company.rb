# -*- encoding : utf-8 -*-

include_set Abstract::Media
include_set Abstract::Delist
include_set Abstract::Accountable
include_set Abstract::Stewardable
include_set Abstract::TwoColumnLayout

include_set Abstract::Bookmarkable
# include_set Abstract::Export

card_accessor :alias, type: PointerID
card_accessor :metric_answer
card_accessor :image
card_accessor :incorporation

event :validate_company_name, :validate, changed: :name, on: :save do
  errors.add :name, "Use ＋ instead of + in company name" if name.compound?
end

event :ensure_wikipedia_mapping_attempt, :validate, on: :create do
  ensure_subfield :wikipedia
end

event :delete_all_company_answers, :validate, on: :delete do
  answers.delete_all
  skip_event! :schedule_answer_counts,
              :update_related_calculations,
              :update_related_scores,
              :update_related_verifications
end

def headquarters_jurisdiction_code
  headquarters_card&.item_cards&.first&.oc_code
end

def add_alias alias_name
  alias_card.insert_item! 0, alias_name
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
  related_company_ids(args).map(&:cardname)
end

# @return [Array] of Integers
def inverse_related_company_ids args={}
  inverse_relationships(args).distinct.pluck :subject_company_id
end

private

def normalize_metric_arg args={}
  return unless (metric = args.delete :metric)

  args[:metric_id] = metric.card_id
end

# DEPRECATED.  +answer csv replaces following:
format :csv do
  view :core do
    Answer.csv_title + card.answers.map(&:csv_line).join
  end
end
