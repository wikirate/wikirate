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
    card.unit.present? ? card.unit : ""

    # if card.unit.present?
    #   card.unit
    # elsif card.range.present?
    #   card.range.to_s
    # elsif card.categorical?
    #   ""
    #   # category_legend
    # else
    #   ""
    # end
  end

  # maybe following should be view of :value_options card?
  def category_legend
    category_legend_options.join ", "
  end

  def category_legend_options
    @category_legend_options ||=
      card.value_option_names.reject { |o| ::Answer.unknown? o }
  end
end

format :html do
  def wrap_legend
    return "" unless (legend_core = yield)&.present?

    wrap_with(:span, class: "metric-legend") { legend_core }
  end

  def category_legend
    wrap_with :span, class: "small", title: "value options" do
      [icon_tag(:list), limited_category_legend_options].flatten.compact.join " "
    end
  end

  private

  def limited_category_legend_options
    options = category_legend_options
    commaed = options.join ", "
    return commaed unless commaed.length > 5

    category_popover_link commaed[0..40], options.join("</br>")
  end

  def category_popover_link short_options, full_options
    popover_link full_options, nil, short_options,
                 "data-html": "true", path: "#", class: "_over-card-link"
  end
end
