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
    :deckorate_tabbed_layout
  end

  view :page do
    wrap { [naming { render_rich_header }, render_flash, render_tabs] }
  end

  view :content do
    render_page
  end
end
