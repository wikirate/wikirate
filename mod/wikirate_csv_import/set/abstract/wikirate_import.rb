include_set Abstract::Import
include_set Abstract::Header
include_set Abstract::Tabs

format :html do
  def header_text
    download_link
  end

  view :header do
    main? ? render_main_header : super()
  end

  view :main_header do
    [render_type_link, render_rich_header]
  end

  def tab_list
    %i[import_map import_status]
  end

  def tab_options
    { import_map: { label: "Step 1: Map Data" },
      import_status: { label: "Step 2: Import Items" } }
  end

  view :core do
    wrap_with :div, class: "nodblclick" do
      render_tabs
    end
  end

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
