include_set Abstract::FluidLayout
include_set Abstract::AboutPages

format :html do
  def edit_fields
    absolutize_edit_fields %i[platform_main_heading platform_vision platform_mission] +
                           %i[about blurb].card.item_names +
                           %i[value blurb].card.item_names +
                           %i[our_story about_cta contact_cta1 contact_cta2]
  end

  def breadcrumb_title
    "About Wikirate"
  end

  view :page, template: :haml, cache: :deep
end
