
format :html do
  def header_right
    render_title_with_bookmark
  end

  view :thumbnail_with_bookmark do
    wrap_with :div, class: "thumbnail-with-bookmark" do
      [render_bookmark, try(:thumbnail)]
    end
  end
end
