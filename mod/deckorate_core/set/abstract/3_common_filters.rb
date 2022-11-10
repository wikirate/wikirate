format :html do
  def self.define_filter_types hash
    hash.each do |filter_key, filter_type|
      define_method("filter_#{filter_key}_type") { filter_type }
    end
  end

  define_filter_types dataset: :multiselect,
                      year: :check,
                      wikirate_topic: :multiselect,
                      company_category: :check,
                      company_group: :check,
                      company_name: :text,
                      country: :check,
                      published: :radio

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

  def filter_dataset_options
    type_options :dataset
  end

  def filter_wikirate_topic_options
    type_options :wikirate_topic
  end

  def filter_company_group_options
    type_options :company_group
  end

  def filter_country_options
    :core_country.card.value_options_card.item_names
  end

  def filter_published_options
    {
      "Published only"   => "true",
      "Unpublished only" => "false",
      "Either"           => "all"
    }
  end
end
