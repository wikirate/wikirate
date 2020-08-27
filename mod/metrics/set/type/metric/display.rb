
format do
  view :legend do
    value_legend
  end

  def wrap_legend
    yield
  end

  def value_legend
    if card.unit.present?
      card.unit
    elsif card.range.present?
      card.range.to_s
    elsif card.categorical?
      category_legend
    else
      ""
    end
  end

  def category_legend
    category_legend_options.join ", "
  end

  def category_legend_options
    card.value_options.reject { |o| Answer.unknown? o }
  end
end

format :html do
  def wrap_legend
    return "" unless (legend_core = yield)&.present?

    wrap_with(:span, class: "metric-legend") { legend_core }
  end

  def category_legend
    wrap_with :div, class: "small", title: "value options" do
      [fa_icon("list"), limited_category_legend_options].flatten.compact.join " "
    end
  end

  def limited_category_legend_options
    commaed = category_legend_options.join ", "
    return commaed unless commaed.length > 40

    [comma[0..40],
     popover_link(options.join("<br>"), nil, fa_icon("ellipsis-h"),
                  "data-html": "true", path: "javascript:",
                  class: "border text-muted px-1")]
  end

  # OUTLIERS

  view :outliers do
    outs = Savanna::Outliers.get_outliers prepare_for_outlier_search, :all
    outs.inspect
  end

  def prepare_for_outlier_search
    res = {}
    card.metric_answer_card.values_by_name.map do |key, data|
      data.each do |row|
        res["#{key}+#{row['year']}"] = row["value"].to_i
      end
    end
    res
  end
end
