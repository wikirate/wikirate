include_set Type::SearchType
include_set Abstract::WikirateTable
include_set Abstract::Table

include_set Abstract::MetricChild, generation: 3
include_set Abstract::BrowseFilterForm
include_set Abstract::BookmarkFiltering

def filter_keys
  %i[name company_group bookmark project]
end

def filter_class
  CompanyFilterQuery
end

def default_sort_option
  "answer"
end

def default_filter_hash
  { name: "" }
end

def bookmark_type
  :wikirate_company
end

def target_type_id
  WikirateCompanyID
end

def relationship_answers
  relationship_ids.map(&:card)
end

def relationship_ids
  return [] if Env.params[:filter] && other_company_ids.empty?
  Relationship.where(relationship_query).pluck(:relationship_id)
end

def other_company_ids
  @other_company_ids ||= Env.params[:filter] ? search(return: :id) : []
end

def relationship_query
  base = { answer_company_id_field => company_id, year: year }
  return base unless other_company_ids.present?
  base.merge other_company_id_field => other_company_ids.unshift("in")
end

def inverse?
  metric_card.inverse?
end

def answer_company_id_field
  inverse? ? :object_company_id : :subject_company_id
end

def other_company_id_field
  inverse? ? :subject_company_id : :object_company_id
end

format :html do
  delegate :metric, :company, :year, :inverse?, to: :card

  def quick_filter_list
    bookmark_quick_filter + company_group_quick_filters + project_quick_filters
  end

  def sort_options
    { "Most Answers": :answer,
      "Most Metrics": :metric }.merge super
  end

  view :core, cache: :never, template: :haml

  def add_relation_link
    link_to_card :research_page, "Add relation",
                 class: "slotter btn btn-sm btn-primary",
                 path: { view: :add_relation,
                         metric: metric, company: company, year: year }
  end

  def relations_table value_view=:details
    name_view = inverse? ? :inverse_company_name : :company_name
    wikirate_table :company, card.relationship_answers, [name_view, value_view],
                   header: [rate_subject, "Answer"]
  end
end

