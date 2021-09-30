include_set Abstract::ProjectFilter

format :html do
  view :titled_content do
    [field_nest(:description), render_filtered_content]
  end
end
