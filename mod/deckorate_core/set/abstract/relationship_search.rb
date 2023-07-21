include_set Abstract::DeckorateFiltering
include_set Abstract::CommonFilters
include_set Abstract::LookupSearch
include_set Abstract::SearchViews
include_set Abstract::DetailedExport
include_set Abstract::MetricSearch
include_set Abstract::AnswerFilters

def item_type_id
  RelationshipAnswerID
end

def query_class
  RelationshipQuery
end

format do
  def default_sort_option
    :updated_at
  end

  def filter_map
    [:year,
     { key: :wikirate_company,
       type: :group,
       filters: [:subject_company_name, :object_company_name] },
     { key: :metric,
       type: :group,
       open: true,
       filters: shared_metric_filter_map.unshift(:metric_name) },
     { key: :metric_answer,
       type: :group,
       filters: [{ key: :value, open: true }, :updated] }
     ]
  end
end