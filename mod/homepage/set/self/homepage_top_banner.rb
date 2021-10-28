include_set Abstract::HamlFile

format :html do
  def companies
    Card[:wikirate_company, :featured].item_names
  end

  def topics
    Card[:wikirate_topic, :featured].item_names.map { |n| words_after_colon n }
  end

  def words_after_colon string
    string.gsub(/^.*\:\s*/, "")
  end

  def adjectives
    Card[:homepage_adjectives].item_names
  end
end
