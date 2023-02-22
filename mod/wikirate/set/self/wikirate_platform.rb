include_set Abstract::FluidLayout
include_set Abstract::AboutPages

format :html do
  def edit_fields
    absolutize_edit_fields %i[platform_main_heading platform_vision platform_mission] +
                           %i[wikirate_platform blurb].card.item_names +
                           %i[value blurb].card.item_names +
                           [:our_story]
  end

  def breadcrumb_title
    "About WikiRate"
  end

  view :page, template: :haml
end
