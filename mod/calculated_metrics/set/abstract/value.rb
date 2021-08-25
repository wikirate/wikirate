event :update_related_calculations, :after_integrate, skip: :allowed do
  ensure_metric(metric_card).update_depender_values_for! company_id
end
