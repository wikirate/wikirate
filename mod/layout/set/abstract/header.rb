format :html do
  view :rich_header do
    bs_layout do
      row 12, class: "rich-header" do
        html render_menu
        col class: "p-0 border-bottom" do
          _render_rich_header_body
        end
      end
    end
  end

  view :rich_header_body do
    header_body :large
  end

  # TODO: this should be header_title, but that's taken by what should be
  # frame_header_title
  def header_right
    render_title_link
  end

  def header_body size=:medium
    text_with_image title: header_right, text: header_text, size: size
  end

  def header_text
    ""
  end

  view :shared_header do
    header_body
  end
end
