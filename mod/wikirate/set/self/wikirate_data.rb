include_set Abstract::FluidLayout
include_set Abstract::AboutPages

format :html do
  def edit_fields
    absolutize_edit_fields %i[data_main_heading data_special data_reliable] +
                           %i[wikirate_data list].card.item_names +
                           %i[wikirate_data blurb].card.item_names +
                           [:data_usage]
  end

  view :page, template: :haml, cache: :deep

  def breadcrumb_title
    "Data"
  end
end
