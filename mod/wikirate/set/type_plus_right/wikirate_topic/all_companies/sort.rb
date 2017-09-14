format do
  def sort_by
    @sort_by ||= Env.params["sort"] || "most_metrics"
  end

  def sort_order
    "desc"
  end

  def sort values
    case sort_by
    when "most_notes"
      sort_by_desc values, "note"
    when "most_sources"
      sort_by_desc values, "source"
    when "has_overview"
      sort_by_overview values
    else # "most_metrics"
      sort_by_desc values, "metric"
    end
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
      x_overview = overview? x[0]
      y_overview = overview? y[0]
      if x_overview == y_overview
        x[0] <=> y[0]
      else
        y_overview - x_overview
      end
    end
  end
end
