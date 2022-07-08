format :html do
  view :filtered_content do
    field_nest :status_list, view: :tabs
  end
end
