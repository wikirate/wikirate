format :html do
  layout :guide_layout, view: :guide_page do
    wikirate_layout "wikirate-one-full-column-layout guide-layout px-2" do
      layout_nest
    end
  end
end
