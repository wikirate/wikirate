include_set Abstract::DeckorateFiltering
include_set Abstract::CommonFilters
include_set Abstract::LookupSearch
include_set Abstract::SearchViews
include_set Abstract::DetailedExport

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
end