# -*- encoding : utf-8 -*-

include_set Abstract::Media
include_set Abstract::Delist
include_set Abstract::AccountHolder
include_set Abstract::Bookmarker
include_set Abstract::Stewarder
include_set Abstract::DeckorateTabbed
include_set Abstract::JsonldSupported

include_set Abstract::Bookmarkable
include_set Abstract::SearchContentFields
include_set Abstract::Designer

card_accessor :alias, type: :list
card_accessor :answer, type: :search_type
card_accessor :metric, type: :search_type
card_accessor :image
card_accessor :incorporation
card_accessor :headquarters, type: :pointer
card_accessor :isin
card_accessor :wikirate_website, type: :phrase

event :validate_company_name, :validate, changed: :name, on: :save do
  errors.add :name, "Use ＋ instead of + in company name" if name.compound?
end

event :ensure_wikipedia_mapping_attempt, :validate, on: :create do
  field :wikipedia
end

event :delete_all_company_answers, :store, on: :delete do
  answers.delete_all
  skip_event! :schedule_answer_counts,
              :update_related_calculations,
              :update_related_scores,
              :update_related_verifications
end

def headquarters_jurisdiction_code
  headquarters_card&.item_cards&.first&.oc_code
end

# def add_alias alias_name
#   alias_card.insert_item! 0, alias_name
# end

# @return [Answer]
def latest_answer metric
  answer(metric: metric, latest: true).first
end

# @return [Answer::ActiveRecord_Relation]
def answers args={}
  args[:company_id] = id
  normalize_metric_arg args
  ::Answer.where args
end

# @return [Relationship::ActiveRecord_Relation]
def relationships args={}
  args[:subject_company_id] = id
  normalize_metric_arg args
  ::Relationship.where args
end

# @return [Relationship::ActiveRecord_Relation]
def inverse_relationships args={}
  args[:object_company_id] = id
  normalize_metric_arg args
  ::Relationship.where args
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

# ids of metrics that do not apply to this company (because of company group restriction)
def inapplicable_metric_ids
  company_group_condition =
    if (cg_ids = company_group_ids)&.any?
      { not: { refer_to: { "id": ["in"] + cg_ids } } }
    else
      {}
    end

  Card.search(
    type: :metric,
    return: :id,
    limit: 0,
    right_plus: [:company_group, company_group_condition]
  )
end

# ids of company groups of which company is a member
def company_group_ids
  Card.search(
    type: :company_group,
    return: :id,
    right_plus: [
      :company,
      { refer_to: id }
    ]
  )
end

def search_content_field_codes
  [:alias]
end

private

def normalize_metric_arg args={}
  return unless (metric = args.delete :metric)

  args[:metric_id] = metric.card_id
end
