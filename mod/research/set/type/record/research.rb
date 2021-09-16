format :html do
  RESEARCH_TABS = {
    question: "Question",
    source: "Source",
    answer: "Answer"
  }.freeze

  # view :data do
  #   render_research_button + super()
  # end

  layout :research_layout, view: :research do
    wikirate_layout "wikirate-one-full-column-layout research-layout px-2" do
      layout_nest
    end
  end

  def layout_for_view view
    :research_layout if view&.to_sym == :research
  end

  def research_tab_map
    index = 0
    RESEARCH_TABS.each_with_object({}) do |(codename, title), hash|
      index += 1
      hash[codename] = {
        view: :"#{codename}_phase",
        title: research_tab_title(index, title),
        button_attr: { class: "btn btn-outline-secondary" }
      }
    end
  end

  def research_tab_title num, title
    haml :research_tab_title, num: num, title: title
  end

  def default_research_tab
    params[:tab] || :question_phase
  end

  view :research do
    tabs research_tab_map, default_research_tab,
         load: :lazy, tab_type: "pills container justify-content-around" do
      render default_research_tab
    end
  end

  view :answer_phase, template: :haml
end
