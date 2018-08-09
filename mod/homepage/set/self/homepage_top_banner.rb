include_set Abstract::HamlFile

format :html do
  def companies
    Card[:homepage_featured_companies].item_names
  end

  def topics
    Card[:homepage_featured_topics].item_names
  end

  def adjectives
    Card[:homepage_adjectives].item_names
  end
end
