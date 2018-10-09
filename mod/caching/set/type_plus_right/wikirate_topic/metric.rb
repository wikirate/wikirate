# cache # of metrics tagged with this topic (=_left) via <metric>+topic
include_set Abstract::TaggedByCachedCount, type_to_count: :metric,
                                           tag_pointer: :wikirate_topic
include_set Abstract::Table

def metric_ids
  search return: :id, limit: 0
end

# FIXME: this has nothing to do with topics and should be somewhere more general
def metric_ids_with_answers_by_company_count
  Answer.group(:metric_id)
        .where(metric_id: metric_ids)
        .order("count_distinct_company_id desc")
        .count("distinct company_id")
        .map(&:first)
end

def metric_ids_by_company_count
  metric_ids_with_answers_by_company_count | metric_ids
end

def metrics_by_company_count
  metric_ids_by_company_count.map { |id| Card[id] }
end

format do
  def search_with_params _args={}
    card.metrics_by_company_count
  end
end
