format :html do
  view :answer_phase, template: :haml

  def answer
    raise Card::Error, "no current year" unless current_year

    @answer ||= Card.fetch card.name.field_name(current_year),
                           new: { type: :metric_answer }
  end
end