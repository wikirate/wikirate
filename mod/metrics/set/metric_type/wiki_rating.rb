include Set::Abstract::Calculation

format :html do
  # def metric_designer_field options={}
  #   super options.merge(readonly: true)
  # end

  def thumbnail_metric_info
    "WikiRating"
  end
end

event :create_formula, :initialize, on: :create do
  add_subfield :formula, content: "{}" unless subfield(:formula)&.content&.present?
end
