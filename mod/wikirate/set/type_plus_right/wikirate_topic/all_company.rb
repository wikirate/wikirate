include_set TypePlusRight::WikirateCompany::AllMetricValues

def raw_content
  # cannot leave it empty
  %({ "name":"Home" })
end

def sort_params
  [(Env.params["sort"] || "most_metrics"), "desc"]
end

def filter metric
  filter_by_name(metric)
end

def cached_values
  @cached_metric_values ||= values_by_name
  if @cached_metric_values
    result = @cached_metric_values.select do |metric, _values|
      filter metric
    end
    result
  else
    @cached_metric_values
  end
end

format do
  def analysis_cached_count company, type
    search_card = Card.fetch "#{company}+#{card.cardname.left}+#{type}"
    count_card = search_card.fetch trait: :cached_count, new: {}
    count_card.format.render_core.to_i
  end

  def sort_by_desc companies, type
    companies.sort do |x, y|
      value_a = analysis_cached_count x[0], type
      value_b = analysis_cached_count y[0], type
      value_b - value_a
    end
  end

  def overview? company
    Card.exists?("#{company}+#{card.cardname.left}+review") ? 1 : 0
  end

  def sort_by_overview companies
    companies.sort do |x, y|
      x_overview = overview?x[0]
      y_overview = overview?y[0]
      if x_overview == y_overview
        x[0] <=> y[0]
      else
        y_overview - x_overview
      end
    end
  end

  def sorted_result sort_by, _order, _is_num=true
    cached_values = card.filtered_values_by_name
    case sort_by
    when "most_notes"
      sort_by_desc cached_values, "note"
    when "most_sources"
      sort_by_desc cached_values, "source"
    when "has_overview"
      sort_by_overview cached_values
    else # "most_metrics"
      sort_by_desc cached_values, "metric"
    end
  end
end
format :html do
  def page_link_params
    [:name, :sort]
  end

  view :card_list_items do |args|
    search_results.map do |row|
      c = Card.fetch row[0]
      render :card_list_item, args.clone.merge(item_card: c)
    end.join "\n"
  end

  view :card_list_header do
    ""
  end
end
