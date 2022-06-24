format :html do
  def layout_name_from_rule
    :deckorate_jumbotron_layout
  end

  view :page do
    "please override page view"
  end
end
