include_set Abstract::CompanySearch
include_set Abstract::TaskFilter

assign_type :search_type

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
