include_set Abstract::HamlFile

format :html do
  def companies
    Card[:homepage_featured_companies].item_names
  end

  def topics
    Card[:homepage_featured_topics].item_names.map { |n| words_after_colon n }
  end

  def words_after_colon string
    string.gsub /^.*\:\s*/, ""
  end

  def adjectives
    Card[:homepage_adjectives].item_names
  end
end
