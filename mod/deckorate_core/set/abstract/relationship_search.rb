include_set Abstract::DeckorateFiltering
include_set Abstract::CommonFilters
include_set Abstract::LookupSearch
include_set Abstract::SearchViews
include_set Abstract::DetailedExport
include_set Abstract::MetricSearch
include_set Abstract::AnswerFilters
include_set Abstract::JsonldSupported

delegate :inverse?, to: :metric_card

def item_type_id
  RelationshipID
end

def query_class
  RelationshipQuery
end

format do
  delegate :inverse?, to: :card

  def default_sort_option
    :updated_at
  end

  def filter_map
    [
      :year,
      { key: :company,
        type: :group,
        filters: [:subject_company_name, :object_company_name] },
      { key: :metric,
        type: :group,
        open: true,
        filters: super },
      { key: :answer,
        type: :group,
        filters: [{ key: :value, open: true }, :updated] }
    ]
  end
end

format :json do
  view :answer_list, cache: :never do
    query.lookup_relation.map(&:compact_json)
  end
end

format :csv do
  view :titles do
    ::Relationship.csv_titles detailed?
  end

  view :body do
    detailed = detailed?
    query.lookup_relation.map { |row| row.csv_line detailed }
  end

  # def default_limit
  #   nil
  # end
end
