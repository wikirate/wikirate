event :update_related_calculations, :integrate_with_delay,
      skip: :allowed, priority: 50 do
  return unless (m = try(:metric_card))

  ensure_metric(m).update_depender_values_for! company_id
end
