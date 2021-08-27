format :html do
  def layout_name_from_rule
    :guide_layout
  end

  layout :guide_layout, view: :guide_page do
    wikirate_layout "wikirate-one-full-column-layout guide-layout px-2" do
      layout_nest
    end
  end

  view :guide_page, template: :haml
end
