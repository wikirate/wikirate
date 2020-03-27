# ImportWithMapping extends import functionality to support a mapping stage.
#
# This is for imports where:
#   1. at least one of the CSV columns contains content that must refer to
#      and existing card, AND
#   2. the import needs to deal with inexact matches in the CSV content


include_set Abstract::Import
include_set Abstract::TwoColumnLayout

format :html do
  def header_text
    download_link
  end

  view :right_column do
    wrap_with :div, class: "progress-column" do
      [render_type_link, field_nest(:import_status, view: :core)]
    end
  end

  view :data do
    field_nest :import_map, view: :core
  end

  view :bar_right do
    field_nest :import_status, view: :progress_bar
  end
end
