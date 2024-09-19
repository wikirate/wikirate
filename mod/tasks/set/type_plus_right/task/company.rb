include_set Type::SearchType
include_set Abstract::CompanySearch
include_set Abstract::TaskFilter

format do
  def default_sort_option
    "answer"
  end
end

format :html do
  def default_item_view
    :box
  end
end
