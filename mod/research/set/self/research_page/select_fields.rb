format :html do
  def metric_select
    research_select_tag :metric, metric_list, metric
  end

  def year_select
    research_select_tag :year, year_list, year
  end

  def research_select_tag name, items, selected
    tag = SelectTagWithHtmlOptions.new(name, self,
                                       url: ->(item) { research_url(name => item) })
    tag.render(items, selected: selected)
  end
end
