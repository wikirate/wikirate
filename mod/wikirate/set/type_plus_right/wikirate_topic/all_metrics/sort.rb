include_set Abstract::SortMetrics

format do
  def sort values
    if sort_by == "company_number"
      sort_company_number_desc values
    else
      super
    end
  end

  def metric_company_count metric
    metric_company = Card[metric].fetch trait: :wikirate_company
    metric_company_count = metric_company.fetch trait: :cached_count, new: {}
    metric_company_count.format.render_core.to_i
  end

  def sort_company_number_desc metrics
    metrics.sort do |x, y|
      metric_company_count(y[0]) - metric_company_count(x[0])
    end
  end
end
