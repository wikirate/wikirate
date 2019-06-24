include_set Abstract::FilterableBar

format :html do
  def topic
    card.left
  end

  def company_id
    Card.fetch_id card.name.right
  end

  def topic_metric
    topic.fetch(trait: :metric, new: {})
  end

  def answer_count
    ::Answer.where(metric_id: topic_metric.item_ids, company_id: company_id).count
  end

  view :bar_left do
    filterable status: :exists, year: :latest, wikirate_topic: card.name.left do
      nest topic, view: :bar_left
    end
  end

  view :bar_right do
    [answer_count_badge, metric_count_badge]
  end

  def answer_count_badge
    labeled_badge answer_count, "Answers", klass: "RIGHT-answer"
  end

  def metric_count_badge
    labeled_badge topic_metric.count, "Metrics", klass: "RIGHT-metric"
  end

  view :bar_bottom do
    nest topic, view: :data
  end

  def full_page_card
    topic
  end
end
