# The answer "legend" is the qualifying detail that typically follows the value
# Can involve unit, range, categories, etc.

format do
  view :legend do
    wrap_legend { value_legend }
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

  # maybe following should be view of :value_options card?
  def category_legend
    category_legend_options.join ", "
  end

  def category_legend_options
    @category_legend_options ||= card.value_options.reject { |o| Answer.unknown? o }
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

    [commaed[0..40], category_popover_link]
  end

  def category_popover_link
    popover_link category_legend_options.join("</br>"), nil, fa_icon("ellipsis-h"),
                 "data-html": "true", path: "javascript:", class: "border text-muted px-1"
  end
end
