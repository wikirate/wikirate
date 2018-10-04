format :html do
  view :with_cited_button do
    with_toggle do
      with_cite_button(cited: true)
    end
  end

  view :source_and_preview, cache: :never do
    wrap do
      [
        with_cite_button(cited: inherit(:source_cited),
                         disabled: inherit(:source_disabled)),
        render_iframe_view.html_safe,
        hidden_information.html_safe
      ]
    end
  end

  view :relevant do
    with_toggle do
      with_cite_button
    end
  end

  view :cited, cache: :never do
    if voo.show? :cited_source_links
      wrap_with_info { _render_bar }
    else
      with_toggle do
        wrap_with_info { _render_bar }
      end
    end
  end

  def with_cite_button cited: false, disabled: false
    voo.hide :links
    wrap_with_info do
      [
        _render_bar,
        cite_button(cited, disabled),
        hidden_item_input
      ]
    end
  end

  def cite_button cited, disabled=false
    klass = cited ? "btn-primary _cited_button" : "btn-secondary _cite_button"
    wrap_with :div, class: "pull-right" do
      wrap_with :a, href: "#", class: "btn #{klass} c-btn #{'disabled' if disabled}" do
        cited ? "Cited!" : "Cite!"
      end
    end
  end

  def hidden_item_input
    tag :input, type: "hidden", class: "_pointer-item", value: card.name
  end
end
