# cache # of metrics tagged with this topic (=_left) via <metric>+topic
include_set Abstract::TaggedByCachedCount, type_to_count: :metric,
                                           tag_pointer: :wikirate_topic

def metric_ids
  search return: :id, limit: 0
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
      next if Answer.exists?(metric_id: id)
      nest id, view: :listing
    end.compact
  end

  def all_metric_ids
    @all_metric_ids ||= card.metric_ids
  end
end
