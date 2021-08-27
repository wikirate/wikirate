format :html do
  def layout_name_from_rule
    :wikirate_one_full_column_layout
  end

  def default_page_view
    :guide_page
  end

  view :guide_page, template: :haml
end