include_set Type::SearchType
include_set Abstract::Table
include_set Abstract::Export
include_set Abstract::MetricChild, generation: 3
include_set Abstract::BrowseFilterForm
include_set Abstract::BookmarkFiltering

def bookmark_type
  :wikirate_company
end

def target_type_id
  WikirateCompanyID
end

def relationship_answers paging_args={}
  relationship_ids(paging_args).map(&:card)
end

def relationship_ids paging_args={}
  return [] if Env.params[:filter] && other_company_ids.empty?
  relationship_relation(paging_args).pluck :relationship_id
end

def other_company_ids
  @other_company_ids ||= Env.params[:filter] ? search(return: :id, limit: 0) : []
end

# TODO: move paging handling to format.
def relationship_relation paging={}
  Relationship.where(relationship_query)
              .limit(paging.key?(:limit) ? paging[:limit] : 20)
              .offset(paging.key?(:offset) ? paging[:offset] : 0)
end

def relationship_query
  base = { metric_card.answer_lookup_field => left.id }
  return base unless other_company_ids.present?
  base.merge other_company_id_field => other_company_ids.unshift("in")
end

def inverse?
  metric_card.inverse?
end

def other_company_id_field
  metric_card.inverse_company_id_field
end

format do
  def filter_class
    CompanyFilterQuery
  end

  def filter_keys
    %i[name company_group bookmark project]
  end

  def default_sort_option
    "answer"
  end

  def default_filter_hash
    { name: "" }
  end

  def quick_filter_list
    bookmark_quick_filter + company_group_quick_filters + project_quick_filters
  end

  def sort_options
    { "Most Answers": :answer,
      "Most Metrics": :metric }.merge super
  end

  def count_with_params
    Relationship.where(card.relationship_query).count
  end
end

format :html do
  delegate :metric, :company, :year, :inverse?, to: :card
  view :core, template: :haml

  def add_relation_link
    link_to_card :research_page, "Add relation",
                 class: "slotter btn btn-sm btn-primary",
                 path: { view: :add_relation,
                         metric: metric,
                         company: company,
                         year: year,
                         related_company: "" }
  end

  view :relations_table, cache: :never do
    name_view = inverse? ? :inverse_company_name : :company_name
    with_paging do |paging_args|
      wikirate_table :company,
                     card.relationship_answers(paging_args),
                     [name_view, :details],
                     header: [rate_subject, "Answer"]
    end
  end
end

format :csv do
  view :core do
    Relationship.csv_title +
      card.relationship_relation(limit: nil).map(&:csv_line).join
  end
end
