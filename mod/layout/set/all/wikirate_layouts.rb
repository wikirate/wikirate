format :html do
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

  def wikirate_layout body_class
    <<-HTML.strip_heredoc
      <body class="wikirate-layout #{body_class}">
        <div id="fakeLoader"></div>
        #{nest :nav_bar, view: :core}
        #{yield}
        #{nest :wikirate_footer, view: :content}
        #{nest 'ajax loader anime', view: :content}
        #{nest '_main+google analytics conversion snippet', view: :core}
      </body>
    HTML
  rescue
    binding.pry
  end
end
