include_set Abstract::Table
include_set Abstract::MetricChild, generation: 3
include_set Abstract::BrowseFilterForm
include_set Abstract::BookmarkFiltering
include_set Abstract::PublishableField

def bookmark_type
  :wikirate_company
end

def target_type_id
  WikirateCompanyID
end

def query
  { metric_card.answer_lookup_field => left.id }
end

format do
  def relationship_query
    card.query.tap do |query|
      if other_company_ids.present?
        query.merge! other_company_id_field => other_company_ids.unshift("in")
      end
    end
  end

  def search_with_params
    skip_lookup? ? [] : super
  end

  def relationships
    skip_lookup? ? [] : super
  end

  def skip_lookup?
    Env.params[:filter] && other_company_ids.empty?
  end

  def other_company_ids
    @other_company_ids ||= Env.params[:filter] ? filtered_company_ids : []
  end

  def other_company_id_field
    metric_card.inverse_company_id_field
  end

  def filter_keys
    %i[name company_group bookmark dataset]
  end

  def default_sort_option
    "answer"
  end

  def default_filter_hash
    { name: "" }
  end

  def sort_options
    { "Most Answers": :answer,
      "Most Metrics": :metric }.merge super
  end
end

format :html do
  delegate :metric, :company, :year, to: :card

  view :core, template: :haml

  view :relations_table, cache: :never do
    name_view = inverse? ? :inverse_company_name : :company_name
    wikirate_table search_with_params,
                   [name_view, :details],
                   header: [rate_subject, "Answer"],
                   table: { class: "company" }
  end

  def quick_filter_list
    bookmark_quick_filter + company_group_quick_filters + dataset_quick_filters
  end

  def add_relation_link
    link_to_card :research_page, "Add relation",
                 class: "slotter btn btn-sm btn-primary",
                 path: { view: :add_relation,
                         metric: metric,
                         company: company,
                         year: year,
                         related_company: "" }
  end

  def export_formats
    %i[csv json]
  end
end
