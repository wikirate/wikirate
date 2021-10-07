format :html do
  view :source_phase, template: :haml, cache: :never, wrap: :slot
  view :source_selector, template: :haml, wrap: :research_overlay, cache: :never

  def current_source
    params[:source]
  end

  def source_data
    { source: current_source }
  end
end
