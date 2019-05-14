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
    wrap_with :div, class: "metric-author-info mb-1" do
      link_to_card(card, haml(:author_info, text: text))
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
end
