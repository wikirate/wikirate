include_set Abstract::CommonFilters

def self.metric_type_options
  @metric_type_options ||= %i[
    researched relationship inverse_relationship formula wiki_rating score descendant
  ].map(&:cardname).freeze
end

METRIC_FILTER_TYPES = {
  metric_name: :text,
  research_policy: :select,
  metric_type: :multi,
  designer: :select,
  value_type: :multi
}.freeze

format :html do
  METRIC_FILTER_TYPES.each do |filter_key, filter_type|
    define_method("filter_#{filter_key}_type") { filter_type }
  end

  def filter_designer_options
    Card.cache.fetch "METRIC-DESIGNER-OPTIONS" do
      metrics = Card.search type_id: MetricID, return: :name
      metrics.map do |m|
        names = m.to_name.parts
        # score metric?
        names.length == 3 ? names[2] : names[0]
      end.uniq(&:downcase).sort_by(&:downcase)
    end
  end

  def filter_metric_type_options
    @metric_type_options ||= Abstract::MetricFilters.metric_type_options.dup
  end

  def filter_research_policy_options
    type_options :research_policy
  end

  def filter_value_type_options
    Card.cache.fetch "VALUE-TYPE-OPTIONS" do
      options = Card[:metric, :value_type, :type_plus_right, :content_options].item_names
      options.map(&:to_s)
    end.map(&:to_name)
  end

  def filter_value_type_label
    "Value Type"
  end

  def filter_metric_type_label
    "Metric Type"
  end
end
