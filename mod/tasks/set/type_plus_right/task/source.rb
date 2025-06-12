include_set Abstract::SourceSearch
include_set Abstract::TaskFilter

assign_type :search_type

format do
  def default_sort_option
    "answer"
  end
end
