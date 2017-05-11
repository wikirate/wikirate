
# cache # of metrics tagged with the topic (=lr) related to this analysis (=left)
# and with answers for the company (=rr) related to this analysis
include_set Abstract::SearchCachedCount

def company_card
  left.left
end

def topic_card
  @topic_card ||= left.right
end

def search args={}
  metric_ids = unique_metric_ids

  case args[:return]
  when :id
    metric_ids
  when :count
    metric_ids.count
  when :name
    metric_ids.map { |id| Card.fetch_name id }
  else
    metric_ids.map { |id| Card.fetch id }
  end
end

def unique_metric_ids
  return [] unless topic_card.type_id == WikirateTopicID
  metric_ids = topic_card.fetch(trait: :metric, new: {}).metric_ids
  Answer.where(company_id: company_card.id, metric_id: metric_ids)
        .pluck(:metric_id).uniq
end

# needed for "found_by" wql searches that refer to search results
# of these cards
def wql_hash
  metric_ids = unique_metric_ids
  if metric_ids.any?
    { id: ["in"] + metric_ids }
  else
    { id: -1 } # HACK: ensure no results
  end
end

# turn query caching off because wql_hash varies and fetch_query doesn't recognizes
# changes in wql_hash
def fetch_query args={}
  query(args.clone)
end

def self.notes_for_analyses_applicable_to metric
  metric.analysis_names.map do |analysis_name|
    Card.fetch analysis_name.to_name.trait(:claim)
  end
end

# recount metrics related to Company+Topic (analysis) ...

# ... when <metric>+topic is edited
recount_trigger :type_plus_right, :metric, :wikirate_topic do |changed_card|
  notes_for_analyses_applicable_to changed_card.left
end

# ... when <metric>+company is edited
recount_trigger :type_plus_right, :metric, :wikirate_company do |changed_card|
  notes_for_analyses_applicable_to changed_card.left
end
