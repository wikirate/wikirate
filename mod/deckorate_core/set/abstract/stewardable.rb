# NOTE: this can probably be added into AccountHolder once all abstract sets are preloaded

def stewards_any?
  stewards_all? || designed_metric_ids.any? || assigned_steward_metric_ids.any?
end

def stewards_all?
  Auth.always_ok? || id&.in?(Set::Self::WikirateTeam.member_ids)
end

# note: does NOT return all metrics for Wikirate team members
def stewarded_metric_ids
  return unless real?

  @stewarded_metric_ids ||= (designed_metric_ids + assigned_steward_metric_ids).uniq
end

def designed_metric_ids
  @designed_metric_ids ||= ::Metric.where(designer_id: id).pluck :metric_id
end

def assigned_steward_metric_ids
  @assigned_steward_metric_ids ||=
    Card.search type: :metric, return: :id, right_plus: [:steward, { refer_to: id }]
end
