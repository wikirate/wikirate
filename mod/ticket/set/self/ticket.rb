format :html do
  view :titled_content do
    field_nest :status_list, view: :tabs
  end
end
