include Set::Abstract::Calculation


format :html do
  def metric_designer_field options={}
    super options.merge(disabled: true)
  end
end




