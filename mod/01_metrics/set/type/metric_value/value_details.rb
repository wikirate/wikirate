include_set Abstract::WikirateTable

format :html do
  def value_details args
    case card.metric_type
    when :formula
      _render_formula_value_details(args)
    when :wikirating
      _render_wikirating_value_details(args)
    when :score
      _render_score_value_details(args)
    when :researched
      _render_research_value_details(args)
    end
  end

  def wrap_value_details content, args
    wrap_with :div, class: "metric-value-details collapse" do
      [
        _optional_render(:credit_name, args, :show),
        content,
        content_tag(:div, _render_comments(args), class: "comments-div")
      ]
    end
  end

  view :research_value_details do |args|
    checked_by = card.fetch trait: :checked_by, new: {}
    checked_by = nest(checked_by, view: :double_check_view)
    content =
      [
        content_tag(:div, checked_by.html_safe, class: "double-check"),
        content_tag(:div, _render_sources, class: "cited-sources")
      ]
    wrap_value_details(content, args)
  end

  view :formula_value_details do |args|
    content = wrap_with :div do
      [
        _render_formula_table(args),
        content_tag(:h5, "Formula"),
        nest(card.metric_card.formula_card, view: :core)
      ]
    end
    wrap_value_details(content, args)
  end

  view :wikirating_value_details do |args|
    total = "= ".html_safe + colorify(card.value)
    total = content_tag(:div, total, class: "pull-right")
    content = wrap_with :div do
      [
        _render_wikirating_table,
        content_tag(:div, total, class: "col-md-12")
      ]
    end
    wrap_value_details(content, args)
  end

  view :score_value_details do |args|
    metric_thumbnail = nest(base_metric_card(card), view: :thumbnail)
    value =
      content_tag(:span, base_metric_value(card).value, class: "metric-value")
    content = [[metric_thumbnail, value]]
    table_content = table(content, header: ["Original Metric", "Value"])
    wrap_value_details(table_content.html_safe, args)
  end

  view :formula_table do
    table_content =
      card.metric_card.formula_card.input_cards.map do |item_card|
        next if item_card.type_id == YearlyVariableID
        metric_row(item_card)
      end.compact
    table(table_content, header: ["Metric", "Raw Value", "Score"])
  end

  view :wikirating_table do
    table_content =
      card.metric_card.formula_card.translation_table.map do |card_name, weight|
        card = Card.fetch(card_name)
        metric_row(card, weight)
      end
    columns = ["Metric", "Raw Value", "Score", "Weight", "Points"]
    table(table_content, header: columns)
  end

  def metric_row input_card, weight=""
    wql = input_card.metric_value_query
    wql[:left][:right] = card.company_name
    wql[:right] = card.year
    if (value_card = Card.search(wql).first)
      metric_row_values(input_card, value_card, weight)
    end
  end

  def metric_row_values input_card, value_card, weight
    score_value = ""
    if value_card.metric_type == :score
      score_value = value_card.value
      raw_value = base_metric_value(value_card).value
    else
      raw_value = value_card.value
    end
    raw_value = content_tag(:span, raw_value, class: "metric-value")
    metric_row_content(input_card, weight, raw_value, score_value)
  end

  def metric_row_content input_card, weight, raw_value, score_value
    metric_thumbnail = nest(input_card, view: :thumbnail)
    content_array = [metric_thumbnail, raw_value, colorify(score_value)]
    if card.metric_type == :formula
      content_array
    else
      points = (score_value.to_f * (weight.to_f / 100)).round(1)
      content_array.push("x " + weight + "%", "= " + points.to_s)
    end
  end

  def base_metric_card score_card
    score_card.metric_card.left
  end

  def base_metric_value score_card
    metric = base_metric_card(score_card)
    with_company = metric.field(card.company_name)
    with_company.field(card.year)
  end

  view :value_details_toggle do
    css_class = "fa fa-caret-right fa-lg margin-left-10 btn btn-default btn-sm"
    content_tag(:i, "", class: css_class,
                        data: { toggle: "collapse-next",
                                parent: ".value",
                                collapse: ".metric-value-details"
                              }
               )
  end
end
