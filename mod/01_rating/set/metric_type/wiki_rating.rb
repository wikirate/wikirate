include Set::Abstract::Calculation


format :html do
  def metric_designer_field options={}
    super options.merge(disabled: true)
  end

  def default_content_formgroup_args args
    args[:structure] = 'metric+*type+*edit structure without value type'
  end
end




