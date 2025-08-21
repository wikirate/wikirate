format :html do
  def self.define_filter_types hash
    hash.each do |filter_key, filter_type|
      define_method("filter_#{filter_key}_type") { filter_type }
    end
  end

  define_filter_types dataset: :multiselect,
                      year: :check,
                      topic: :topic,
                      topic_framework: :topic_framework,
                      company_category: :check,
                      company_group: :multiselect,
                      company_keyword: :text,
                      country: :multiselect,
                      company: :multiselect,
                      published: :radio,
                      license: :check

  def filter_company_category_options
    %i[commons company_category].card.value_options_card.options_hash
  end

  def filter_company_category_closer_value val
    filter_company_category_options.invert[val]
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

  def filter_license_options
    Right::License::LICENSES
  end

  def topic_filter field, config
    value = filter_param(field) || config[:default]
    haml :topic_filter, field: field, value: value
  end

  def filter_topic_closer_value val
    val.cardname.right
  end

  def topic_family_quick_filters
    Card::Set::Self::Topic.family_list.item_cards.map do |topic|
      topic_key = topic.right&.codename
      {
        topic: topic.id_string,
        text: topic.name.right,
        icon: icon_tag(topic_key),
        class: "quick-filter-topic-#{topic_key}"
      }
    end
  end

  def topic_framework_filter field, config
    value = filter_param(field) || config[:default]
    haml :framework_filter, field: field, value: value
  end

  def filter_topic_framework_label
    "Mapping"
  end

  def filter_value_array? category
    category.to_sym == :topic ? true : super
  end
end
