
include Card::CachedCount

# recount metrics related to Company+Topic (analysis) ...

# ... when <metric>+topic is edited
ensure_set { TypePlusRight::Metric::WikirateTopic }
recount_trigger TypePlusRight::Metric::WikirateTopic do |changed_card|
  notes_for_analyses_applicable_to changed_card.left
end

ensure_set { TypePlusRight::Metric::WikirateCompany }
recount_trigger TypePlusRight::Metric::WikirateTopic do |changed_card|
  notes_for_analyses_applicable_to changed_card.left
end

def notes_for_analyses_applicable_to metric
  metric.analysis_names.map do |analysis_name|
    Card.fetch analysis_name.to_name.trait(:claim)
  end
end
