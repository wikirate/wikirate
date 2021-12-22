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

  layout :wikirate_one_full_column_layout, view: :titled do
    wikirate_layout "wikirate-one-full-column-layout px-2" do
      layout_nest
    end
  end

  def wikirate_layout body_class
    body_tag "wikirate-layout #{body_class}" do
      <<-HTML.strip_heredoc
        #{nest :nav_bar, view: :core}
        #{yield}
        #{nest :wikirate_footer, view: :content}
        #{nest 'ajax loader anime', view: :content}
        #{nest '_main+google analytics conversion snippet', view: :core}
      HTML
    end
  end
end
