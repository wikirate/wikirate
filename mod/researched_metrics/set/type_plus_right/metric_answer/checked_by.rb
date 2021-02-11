event :update_related_verifications, :after_integrate, skip: :allowed do
  ensure_metric(metric_card).each_depender_metric do |metric|
    Answer.for_card([metric, company_id, year.to_s]).refresh :verification
  end
end
