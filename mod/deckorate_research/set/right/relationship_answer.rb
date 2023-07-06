include_set Abstract::Export
include_set Abstract::DetailedExport
include_set Abstract::BookmarkFiltering
include_set Abstract::CommonFilters

assign_type :search_type

delegate :inverse?, to: :metric_card

def virtual?
  new?
end

format do
  delegate :inverse?, to: :card

  def search_with_params
    @search_with_params ||=
      with_relation_paging(relationships).pluck(:relationship_id).map(&:card)
  end

  def count_with_params
    @count_with_params ||= relationships.count
  end

  def relationships
    Relationship.where relationship_query
  end

  def filtered_company_ids
    if (explicit = params.dig :filter, :company_id)
      [explicit]
    else
      Card.search filter_and_sort_cql.merge(type: :wikirate_company, return: :id)
    end
  end

  def default_sort_option
    nil
  end

  def with_relation_paging relation
    paging = paging_params
    relation.limit(paging[:limit]).offset(paging[:offset])
  end

  def filter_cql_class
    CompanyFilterCql
  end
end

format :json do
  view :answer_list, cache: :never do
    relationships.map(&:compact_json)
  end
end

format :csv do
  view :titles do
    Relationship.csv_titles detailed?
  end

  view :core do
    detailed = detailed?
    relationships.map { |row| row.csv_line detailed }
  end

  def default_limit
    nil
  end
end

format :html do
  # before(:compact_filter_form) { voo.hide :filter_sort_dropdown }

  def export_link_path_args format
    super.merge filter_and_sort_hash
  end
end
