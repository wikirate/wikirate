format :html do
  view :designer_info do
    author_info "Designed by"
  end

  view :scorer_info do
    author_info "Scored by"
  end

  view :designer_info_without_label do
    author_info
  end

  view :scorer_info_without_label do
    author_info
  end

  def author_info text=""
    wrap_with :div, class: "metric-designer-info mb-1" do
      link_to_card(card, haml(:author_info, text: text))
    end
  end

  view :designer_slot do
    voo.hide :menu
    wrap do
      [
        author_info,
        _render_menu
      ]
    end
  end

  def author_image
    wrap_with :div, class: "image-box icon m-0 d-inline-block" do
      wrap_with :span, class: "img-helper" do
        subformat(card.field(:image, new: {}))._render_core size: "small"
      end
    end
  end

  def author
    card.name
  end

  def author_text subtext=nil
    author_label = "#{subtext}#{author}"
    wrap_with :h6, author_label, class: "m-1 d-inline-block"
  end

  # def author_text_with_subtext subtext
  #   wrap_with :div, class: "margin-8" do
  #     [
  #       wrap_with(:h5, author, class: "m-0 p-0"),
  #       %(<span><small class="text-muted">#{subtext}</small></span>)
  #     ]
  #   end
  # end
  #
  # def creator_label subtext
  #   wrap_with :span, subtext, class: "text-muted font-weight-normal"
  # end
  #
  # def author_text
  #   wrap_with :h6, " #{creator_label}#{author}", class: "m-1 d-inline-block"
  # end
  #
  # def author_text_without_subtext
  #
  # end
end
