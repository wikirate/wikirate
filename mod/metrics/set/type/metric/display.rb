DETAILS_FIELD_MAP = {
  number: :numeric_details,
  money: :monetary_details,
  category: :category_details,
  multi_category: :category_details
}.freeze

format :html do
  view :vote do
    %(<div class="d-none d-md-block">#{field_nest(:vote_count)}</div>)
  end

  # OUTLIERS

  view :outliers do
    outs = Savanna::Outliers.get_outliers prepare_for_outlier_search, :all
    outs.inspect
  end

  def prepare_for_outlier_search
    res = {}
    card.all_metric_values_card.values_by_name.map do |key, data|
      data.each do |row|
        res["#{key}+#{row['year']}"] = row["value"].to_i
      end
    end
    res
  end

  # VALUE LEGEND

  view :legend do
    value_legend
  end

  view :legend_core do
    value_legend false
  end

  def value_legend html=true
    # depends on the type
    if card.unit.present?
      card.unit
    elsif card.range.present?
      card.range.to_s
    elsif card.categorical?
      category_legend_display html
    else
      ""
    end
  end

  def category_legend_display html
    html ? category_legend_div : category_legend(", ")
  end

  def category_legend_div
    wrap_with :div, class: "small", title: "value options" do
      ([fa_icon("list")] + options_for_legend).compact.join " "
    end
  end

  def options_for_legend
    legend_core = category_legend ", "
    if legend_core.length > 40
      [legend_core[0..40], link_to_popover(legend_core)]
    else
      [legend_core]
    end
  end

  def link_to_popover  text, title=nil
    opts = { class: "pl-1 text-muted-link border text-muted px-1",
             path: "javascript:", "data-toggle": "popover",
             "data-trigger": :focus, "data-content": text, "data-html": "true" }
    opts["data-title"] = title if title
    link_to fa_icon("ellipsis-h"), opts
  end

  def category_legend joint=", <br>"
    card.value_options.reject { |o| o == "Unknown" }.join joint
  end

  # view :value do
  #   return "" unless args[:company]
  #   %(
  #     <div class="data-item hide-with-details">
  #       {{#{safe_name}+#{h args[:company]}+latest value|concise}}
  #     </div>
  #   )
  # end

  # Weight methods apply only to WikiRatings
  # TODO: hamlize
  def weight_row weight=0, label=nil
    label ||= _render_thumbnail_no_link
    weight = weight_content weight
    output([wrap_with(:td, label, class: "metric-label"),
            wrap_with(:td, weight, class: "metric-weight")]).html_safe
  end

  def weight_content weight
    icon_class = "pull-right _remove-weight btn btn-outline-secondary btn-sm"
    wrap_with :div do
      [text_field_tag("pair_value", weight) + "%",
       content_tag(:span, fa_icon(:close).html_safe, class: icon_class)]
    end
  end
end
