
def virtual?
  new?
end

format :html do
  def topic
    card.left
  end

  def company_id
    card.name.right.card_id
  end

  def topic_metric
    topic.fetch(:metric, new: {})
  end

  def record_count
    ::Answer.where(metric_id: topic_metric.item_ids, company_id: company_id).count
  end

  view :bar_left do
    # filterable topic: card.name.left do
    nest topic, view: :bar_left
    # end
  end

  view :bar_right do
    [record_count_badge, metric_count_badge]
  end

  def record_count_badge
    labeled_badge number_with_delimiter(record_count),
                  icon_tag(:record),
                  klass: "RIGHT-record", title: "Records"
  end

  def metric_count_badge
    labeled_badge topic_metric.count, icon_tag(:metric),
                  klass: "RIGHT-metric", title: "Metrics"
  end

  view :bar_bottom do
    nest topic, view: :data
  end

  def full_page_card
    topic
  end
end
