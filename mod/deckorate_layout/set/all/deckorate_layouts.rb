format :html do
  view :page do
    render_core
  end

  layout :deckorate_layout, view: :titled do
    deckorate_layout :standard do
      wrap_with(:main, class: "container") { layout_nest }
    end
  end

  layout :deckorate_minimal_layout, view: :core do
    deckorate_layout(:minimal, navbar: false) { layout_nest }
  end

  layout :deckorate_fluid_layout, view: :page do
    deckorate_layout :fluid do
      wrap_with(:main) { layout_nest }
    end
  end

  # Used on pages with tabs
  # note: page view
  layout :deckorate_tabbed_layout, view: :page do
    deckorate_layout :tabbed do
      wrap_with(:main, class: "container") { layout_nest }
    end
  end

  layout :deckorate_jumbotron_layout, view: :page do
    deckorate_layout :jumbotron, extra_class: "nodblclick" do
      [haml(:jumbotron_header),
       wrap_with(:div, class: "container py-3") { layout_nest }]
    end
  end

  def deckorate_layout klass, navbar: true, extra_class: ""
    body_tag "deckorate-layout deckorate-#{klass}-layout #{extra_class}" do
      output [(nest(:nav_bar, view: :core) if navbar),
              yield,
              nest(:wikirate_footer, view: :core),
              haml(:ajax_loader_anime)]
    end
  end
end
