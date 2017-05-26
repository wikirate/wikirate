format :html do
  view :core do
    wql_search? ? super() : _render_categories
  end

  view :categories, template: :haml
end
