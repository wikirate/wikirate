def stewards_all?
  id&.in? Set::Self::WikirateTeam.member_ids
end

# note: does NOT return all metrics for WikiRate team members
def stewarded_metric_ids
  return unless real?
  (designed_metric_ids + assigned_steward_metric_ids).uniq
end

def designed_metric_ids
  ::Metric.where(designer_id: id).pluck :metric_id
end

def assigned_steward_metric_ids
  Card.search type: :metric, return: :id, right_plus: [:steward, { refer_to: id }]
end
