format :html do
  def google_analytics_snippet_vars
    super.merge contentGroup1: card.type_name
  end
end
