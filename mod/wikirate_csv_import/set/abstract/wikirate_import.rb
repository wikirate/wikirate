# some of this may eventually be mergeable into Abstract::Import (though the
# two column layout stuff is not yet available outside of WikiRate)
#
# Could also just extend Abstract::Import once extending abstract set mods works.
#

include_set Abstract::Import
include_set Type::File
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
