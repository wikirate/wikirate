format :html do
  def layout_name_from_rule
    :guide_layout
  end

  layout :guide_layout, view: :titled do
    wikirate_layout "wikirate-one-column-layout" do
      wrap_with :div, class: "container" do
        layout_nest
      end
    end
  end
end