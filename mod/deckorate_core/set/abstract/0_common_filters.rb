format :html do
  def self.define_filter_types hash
    hash.each do |filter_key, filter_type|
      define_method("filter_#{filter_key}_type") { filter_type }
    end
  end

  define_filter_types dataset: :multiselect,
                      year: :check,
                      topic: :multiselect,
                      company_category: :check,
                      company_group: :multiselect,
                      company_keyword: :text,
                      country: :multiselect,
                      company: :multiselect,
                      published: :radio

  def filter_company_category_options
    %i[commons company_category].card.value_options_card.options_hash
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

  def filter_topic_options
    type_options :topic
  end

  def filter_company_group_options
    type_options :company_group
  end

  def filter_country_options
    %i[core country].card.value_options_card.item_names
  end

  def filter_company_options
    :company.cardname
  end

  def filter_published_options
    {
      "Published only"   => "true",
      "Unpublished only" => "false",
      "Either"           => "all"
    }
  end
end
