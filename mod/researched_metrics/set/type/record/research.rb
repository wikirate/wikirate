format :html do
  layout :research_layout, view: :research do
    wikirate_layout "wikirate-one-full-column-layout research-layout px-2" do
      layout_nest
    end
  end

  def layout_for_view view
    :research_layout if view == :research
  end

  view :research, template: :haml
end
