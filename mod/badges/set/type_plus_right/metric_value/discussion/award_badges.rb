include_set Abstract::AwardBadge

event :award_metric_value_discussion_badges, before: :refresh_updated_answers,
      on: :update do
  count = update_count + 1
  next unless (badge = earns_badge(count, :update))
  add_badge badge
end
