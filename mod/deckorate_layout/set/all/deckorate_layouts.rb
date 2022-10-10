format :html do
  view :page do
    render_core
  end

  layout :deckorate_layout, view: :titled do
    deckorate_layout "deckorate-standard-layout" do
      wrap_with(:main, class: "container") { layout_nest }
    end
  end

  # Used on pages with tabs
  # note: page view
  layout :deckorate_tabbed_layout, view: :page do
    deckorate_layout "deckorate-tabbed-layout" do
      wrap_with(:main, class: "container") { layout_nest }
    end
  end

  layout :deckorate_jumbotron_layout, view: :page do
    deckorate_layout "deckorate-jumbotron-layout nodblclick" do
      [haml(:jumbotron_header),
       wrap_with(:div, class: "container py-3") { layout_nest }]
    end
  end

  # FIXME: codify conversion snippet handling
  def deckorate_layout body_class
    body_tag "deckorate-layout #{body_class}" do
      output [nest(:nav_bar, view: :core),
              yield,
              nest(:wikirate_footer, view: :content),
              haml(:ajax_loader_anime),
              nest("_main+google analytics conversion snippet", view: :core)]
    end
  end
end
