format :html do
  view :answer_phase, cache: :never, template: :haml, perms: :can_research?

  def current_year
    params[:year]
  end

  def answer
    @answer ||= construct_answer
  end

  private

  def construct_answer
    raise Card::Error, "no current year" unless current_year

    simple_answer.tap { |a| construct_source a }
  end

  def simple_answer
    Card.fetch card.name.field_name(current_year), new: { type: :answer }
  end

  def construct_source answer
    return if answer.real? || current_sources.blank?

    answer.source_card.content = current_sources.to_pointer_content
  end

  def current_sources
    return [] unless params[:source].present?

    Array.wrap params[:source]
  end
end
