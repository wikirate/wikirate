include_set Abstract::Breadcrumbs

format :html do
  def layout_name_from_rule
    :deckorate_fluid_layout
  end

  view :page do
    "please override page view"
  end

  def breadcrumb_items
    [link_to("Home", href: "/"), breadcrumb_title]
  end
end
