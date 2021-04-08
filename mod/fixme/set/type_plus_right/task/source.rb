include_set Type::SearchType
include_set Right::BrowseSourceFilter
include_set Abstract::TaskFilter

format :html do
  def default_sort_option
    "answer"
  end
end
