event :update_related_calculations, :after_integrate, skip: :allowed do
  ensure_metric(metric_card).each_dependent_metric do |metric|
    metric.update_value_for! company: company_id, year: year
  end
end
