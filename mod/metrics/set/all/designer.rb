format :html do
  view :designer_info do
    wrap_with :div, class: "metric-designer-info" do
      link_to_card(card, author_info)
    end
  end

  view :designer_slot do
    voo.hide :menu
    wrap do
      [
        _render_designer_info,
        _render_menu
      ]
    end
  end

  def author_info subtext=nil
    output [
      author_image,
      author_text(subtext)
    ]
  end

  def author_image
    wrap_with :div, class: "image-box small m-0" do
      wrap_with :span, class: "img-helper" do
        subformat(card.field(:image, new: {}))._render_core size: "small"
      end
    end
  end

  def author_text subtext=nil
    if subtext
      author_text_with_subtext subtext
    else
      author_text_without_subtext
    end
  end

  def author
    card.name
  end

  def author_text_with_subtext subtext
    wrap_with :div, class: "margin-8" do
      [
        wrap_with(:h5, author, class: "nopadding"),
        %(<span><small class="text-muted">#{subtext}</small></span>)
      ]
    end
  end

  def author_text_without_subtext
    wrap_with :div do
      wrap_with :h5, author
    end
  end
end
