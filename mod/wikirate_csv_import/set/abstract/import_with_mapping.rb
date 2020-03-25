# ImportWithMapping extends import functionality to support a mapping stage.
#
# This is for imports where:
#   1. at least one of the CSV columns contains content that must refer to
#      and existing card, AND
#   2. the import needs deal with inexact matches in the CSV content


include_set Abstract::Import
include_set Abstract::TwoColumnLayout

card_accessor :import_map, type: :json

event :generate_import_map, :validate, on: :create do
  map = import_map_card
  map.generate_exact!
  add_subcard map
end

format :html do
  def header_text
    download_link
  end

  view :right_column do
    wrap_with :div, class: "progress-column" do
      [render_type_link,
       render_progress_box,
       render_tabs]
      #,
      # render_import_links,
      # render_export_links]
    end
  end

  view :data do
    field_nest :import_map
  end

  view :bar_right do
    field_nest :import_status, view: :progress_bar
  end

  view :progress_box do
    "(Progress bar...)"
  end
end
