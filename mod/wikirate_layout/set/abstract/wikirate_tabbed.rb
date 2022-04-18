include_set Abstract::Header
include_set Abstract::Tabs
include_set Abstract::Media

format do
  view :raw do
    ""
  end
end

format :html do
  def layout_name_from_rule
    :wikirate_tabbed_layout
  end

  def one_line_tab?
    true
  end

  view :page do
    [
      naming { render_rich_header },
      render_tabs
    ]
  end
end
