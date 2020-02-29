def self.metric_type_options
  @metric_type_options ||= %i[
    researched relationship formula wiki_rating score descendant
  ].map(&:cardname).freeze
end

format :html do
  view :filter_metric_name_formgroup, cache: :never do
    text_filter :metric_name
  end

  view :filter_research_policy_formgroup, cache: :never do
    select_filter :research_policy
  end

  view :filter_metric_type_formgroup, cache: :never do
    select_filter :metric_type
  end

  view :filter_designer_formgroup, cache: :never do
    select_filter :designer
  end

  view :filter_value_type_formgroup, cache: :never do
    select_filter :value_type
  end

  def designer_options
    Card.cache.fetch "METRIC-DESIGNER-OPTIONS" do
      metrics = Card.search type_id: MetricID, return: :name
      metrics.map do |m|
        names = m.to_name.parts
        # score metric?
        names.length == 3 ? names[2] : names[0]
      end.uniq(&:downcase).sort_by(&:downcase)
    end
  end

  def metric_type_options
    @metric_type_options ||= Abstract::MetricFilterFormgroups.metric_type_options.dup
  end

  def research_policy_options
    type_options :research_policy
  end

  def value_type_options
    Card.cache.fetch "VALUE-TYPE-OPTIONS" do
      Card[:metric, :value_type, :type_plus_right, :content_options].item_names
    end
  end

  def value_type_filter_label
    "Value Type"
  end

  def metric_type_filter_label
    "Metric Type"
  end
end
