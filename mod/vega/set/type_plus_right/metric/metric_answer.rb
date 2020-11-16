include_set Abstract::Chart

format :json do
  def chart_metric_id
    card.left.id
  end
end

format :html do
  def show_chart?
    super && count_by_status[:known].to_i.positive?
  end
end
