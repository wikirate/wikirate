format :html do
  def layout_name_from_rule
    :wikirate_layout
  end

  layout :wikirate_layout, view: :titled do
    wikirate_layout "wikirate-one-column-layout" do
      wrap_with :div, class: "container" do
        layout_nest
      end
    end
  end

  layout :wikirate_two_column_layout, view: :open do
    wikirate_layout "wikirate-two-column-layout" do
      layout_nest
    end
  end

  layout :wikirate_tabbed_layout, view: :page do
    wikirate_layout "wikirate-tabbed-layout" do
      wrap_with :div, class: "container" do
        layout_nest
      end
    end
  end

  layout :wikirate_one_full_column_layout, view: :titled do
    wikirate_layout "wikirate-one-full-column-layout px-2" do
      layout_nest
    end
  end

  # FIXME: codify conversion snippet handling
  def wikirate_layout body_class
    body_tag "wikirate-layout #{body_class}" do
      output [nest(:nav_bar, view: :core),
              yield,
              nest(:wikirate_footer, view: :content),
              haml(:ajax_loader_anime),
              nest("_main+google analytics conversion snippet", view: :core)]
    end
  end
end
