
# cache # of metrics tagged with the topic (=lr) related to this analysis (=left)
# and with answers for the company (=rr) related to this analysis
include_set Abstract::AnswerTableCachedCount, target_type: :metric

def company_card
  left.left
end

def topic_card
  @topic_card ||= left.right
end

def metric_ids_related_to_topic
  return [] unless topic_card.type_id == WikirateTopicID
  topic_card.fetch(trait: :metric, new: {}).metric_ids
end

def search_anchor
  metric_ids = metric_ids_related_to_topic
  return unless metric_ids.present?
  { company_id: company_card.id, metric_id: metric_ids }
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
