format :html do
  RESEARCH_TABS = {
    question_phase: "Question",
    source_phase: "Source",
    answer_phase: "Answer"
  }.freeze

  # view :data do
  #   render_research_button + super()
  # end

  layout :research_layout, view: :research do
    deckorate_layout "wikirate-one-full-column-layout research-layout nodblclick" do
      layout_nest
    end
  end

  wrapper :research_overlay do
    class_up "card-slot", "d0-card-overlay", :single_use
    @content_body = true
    overlay_frame(true, research_overlay_header) { interior }
  end

  def research_overlay_header
    haml :research_overlay_header
  end

  def layout_for_view view
    :research_layout if view&.to_sym == :research
  end

  def research_tab_map
    index = 0
    RESEARCH_TABS.each_with_object({}) do |(codename, title), hash|
      index += 1
      hash[codename] = {
        view: codename,
        title: research_tab_title(index, title),
        button_attr: { class: "btn btn-outline-secondary" }
      }
    end
  end

  def research_tab_title num, title
    haml :research_tab_title, num: num, title: title
  end

  def default_research_tab
    params[:tab].present? ? params[:tab].to_sym : :question_phase
  end

  view :research, cache: :never, perms: :can_research? do
    tabs research_tab_map, default_research_tab,
         load: :lazy, tab_type: "pills container justify-content-around" do
      render default_research_tab
    end
  end

  def can_research?
    Card.new(type: :answer).ok? :create
  end
end
