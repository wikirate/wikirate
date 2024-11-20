format :html do
  view :answer_phase, cache: :never, template: :haml, perms: :can_research?

  def current_year
    params[:year]
  end

  def record
    @record ||= construct_record
  end

  private

  def construct_record
    raise Card::Error, "no current year" unless current_year

    simple_record.tap { |a| construct_source a }
  end

  def simple_record
    Card.fetch card.name.field_name(current_year), new: { type: :record }
  end

  def construct_source record
    return if record.real? || current_sources.blank?

    record.source_card.content = current_sources.to_pointer_content
  end

  def current_sources
    return [] unless params[:source].present?

    Array.wrap params[:source]
  end
end
