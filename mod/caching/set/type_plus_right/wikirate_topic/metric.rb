# cache # of metrics tagged with this topic (=_left)
include Card::CachedCount

# recount metrics associated with a topic when <metric>+topic is edited
ensure_set { TypePlusRight::Metric::WikirateTopic }
recount_trigger TypePlusRight::Metric::WikirateTopic do |changed_card|
  names = Card::CachedCount.pointer_card_changed_card_names(changed_card)
  names.map do |topic|
    Card.fetch topic.to_name.trait(:metric)
  end
end

format :html do
  view :metric_by_company_count do
    return if all_metric_ids.empty?
    wrap do
      Answer.group(:metric_id)
            .where(metric_id: all_metric_ids)
            .order("count_distinct_company_id desc")
            .count("distinct company_id")
            .map do |metric_id, _count|
        nest metric_id, view: :listing
      end + no_answers
    end
  end

  def no_answers
    all_metric_ids.map do |id|
      next if Answer.exists? id
      nest id, view: :listing
    end.compact
  end

  def all_metric_ids
    @all_metric_ids ||= card.search return: :id, limit: 0
  end
end

