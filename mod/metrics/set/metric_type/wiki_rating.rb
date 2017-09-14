include Set::Abstract::Calculation

format :html do
  # def metric_designer_field options={}
  #   super options.merge(readonly: true)
  # end

  def default_thumbnail_subtitle_args args
    args[:text] ||= ["WikiRating", "designed by"].compact.join " | "
    args[:author] ||= link_to_card card.metric_designer
  end
end

event :create_formula, :initialize, on: :create do
  add_subfield :formula, content: "{}" unless subfield(:formula) &&
                                              subfield(:formula).content
                                                                .present?
end
