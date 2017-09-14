
format :html do
  view :thumbnail do |_args|
    wrap_with :div, class: "metric-thumbnail" do
      _render_thumbnail_text
    end
  end

  view :thumbnail_text do
    wrap_with :div, class: "thumbnail-text" do
      thumbnail_title
    end
  end

  def thumbnail_title
    wrap_with :div, class: "ellipsis" do
      _render_link
    end
  end
end
