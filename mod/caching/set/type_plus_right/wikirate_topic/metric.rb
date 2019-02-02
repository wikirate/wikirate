# cache # of metrics tagged with this topic (=_left) via <metric>+topic
include_set Abstract::TaggedByCachedCount, type_to_count: :metric,
                                           tag_pointer: :wikirate_topic
include_set Abstract::Table

def metric_ids
  search return: :id, limit: 0
end

# FIXME: this has nothing to do with topics and should be somewhere more general
def metric_ids_with_answers_by_company_count metric_ids
  return [] unless metric_ids.present?
  Answer.group(:metric_id)
        .where(metric_id: metric_ids)
        .order("count_distinct_company_id desc")
        .count("distinct company_id")
        .map(&:first)
end

# NOTE: this hard-codes handling so that metrics can _only_ be sorted by company count.
# A better solution would make a special sort case in #search
def item_ids _args={}
  mids = metric_ids
  metric_ids_with_answers_by_company_count(mids) | mids
end

# TODO: paging
def item_cards _args={}
  item_ids.map { |id| Card[id] }
end

format :html do
  def search_with_params
    card.item_cards
  end

  def count_with_params
    card.count
  end

  def paging_needed?
    false
  end
end
