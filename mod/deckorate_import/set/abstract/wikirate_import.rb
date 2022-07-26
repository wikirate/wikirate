include_set Abstract::Import
include_set Abstract::DeckorateTabbed

format :html do
  def header_text
    download_link
  end

  def layout_name_from_rule
    :deckorate_tabbed_layout
  end

  def tab_list
    %i[import_map import_status]
  end

  def tab_options
    { import_map: { label: "Step 1: Matching" },
      import_status: { label: "Step 2: Importing" } }
  end

  # view :core do
  #   wrap_with :div, class: "nodblclick import-core _import-core" do
  #     [render_type_link, download_link, render_tabs]
  #   end
  # end

  view :import_map_tab do
    field_nest :import_map
  end

  view :import_status_tab do
    field_nest :import_status
  end

  view :right_column do
    wrap_with :div, class: "progress-column" do
      [render_type_link, field_nest(:import_status, view: :content)]
    end
  end
end
