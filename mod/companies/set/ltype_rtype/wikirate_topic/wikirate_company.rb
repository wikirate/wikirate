include_set Abstract::FilterableBar

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

  def answer_count
    ::Answer.where(metric_id: topic_metric.item_ids, company_id: company_id).count
  end

  view :bar_left do
    filterable wikirate_topic: card.name.left do
      nest topic, view: :bar_left
    end
  end

  view :bar_right do
    [answer_count_badge, metric_count_badge]
  end

  def answer_count_badge
    labeled_badge number_with_delimiter(answer_count),
                  mapped_icon_tag(:metric_answer),
                  klass: "RIGHT-answer", title: "Answers"
  end

  def metric_count_badge
    labeled_badge topic_metric.count, mapped_icon_tag(:metric),
                  klass: "RIGHT-metric", title: "Metrics"
  end

  view :bar_bottom do
    nest topic, view: :data
  end

  def full_page_card
    topic
  end
end
