format :html do
  view :content_with_anchored_headers do
    wrap { [render_menu, render_core_with_anchored_headers] }
  end

  view :core_with_anchored_headers, cache: :never do
    # start new format so we get fully rendered html (no nest stubs)
    n = Nokogiri::HTML render_core
    n.css("h1, h2, h3, h4, h5, h6").each { |h| h.wrap header_anchor(h) }
    n.to_html
  end

  private

  def header_anchor header
    "<a class='header-anchor' name='#{header.text.to_name.key}'></a>"
  end

  view :infobox do
    wrap { wrap_with("div", class: "wr-infobox") { render_core } }
  end
end
