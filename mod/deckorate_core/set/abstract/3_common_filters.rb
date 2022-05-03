include_set BookmarkFilters

format :html do
  {
    dataset: :autocomplete,
    year: :multi,
    wikirate_topic: :multi,
    company_category: :multi,
    company_group: :multi,
    company_name: :text,
    country: :multi,
    published: :select
  }.each do |filter_key, filter_type|
    define_method("filter_#{filter_key}_type") { filter_type }
  end

  def filter_company_category_options
    :commons_company_category.card.value_options_card.options_hash
  end

  def filter_year_options
    type_options(:year, "desc").each_with_object("Latest" => "latest") do |v, h|
      h[v] = v
    end
  end

  def filter_published_default
    "true"
  end

  def filter_wikirate_topic_options
    type_options :wikirate_topic
  end

  def filter_company_group_options
    type_options :company_group
  end

  def filter_country_options
    Card::Region.countries
  end

  def filter_published_options
    {
      "Published only"   => "true",
      "Unpublished only" => "false",
      "Either"           => "all"
    }
  end
end