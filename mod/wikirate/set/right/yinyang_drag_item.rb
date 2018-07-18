format :html do
  def metric_card
    @metric ||= extract_metric_card
  end
end
