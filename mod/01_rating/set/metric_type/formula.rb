include Set::Abstract::Calculation

format :html do
  def value_type
    'Number'
  end

  def metric_designer_field options={}
    super options.merge(readonly: true)
  end
end