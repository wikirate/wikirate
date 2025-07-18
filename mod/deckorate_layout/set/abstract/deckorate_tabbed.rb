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

  view :page, cache: :yes do
    wrap { [naming { render_rich_header }, render_flash, render_tabs] }
  end

  view :content do
    render_page
  end

  view :details_tab, template: :haml

  def details_tab_cols
    [8, 4]
  end
end
