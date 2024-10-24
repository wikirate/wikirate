format :html do
  view :core, cache: :yes do
    dropdown_button icon_tag(:nav_menu), title: "Navigation Menu" do
      dropdown_items.compact
    end
  end

  private

  def dropdown_items
    [
      dropdown_header("RESOURCES"),
      dropdown_link("Guides", "/guides"),
      dropdown_link("API", "/use_the_API"),
      dropdown_link("FAQ", "/faq"),
      dropdown_link("Recent Changes", "/:recent"),
      dropdown_link("Report Issue", "/ticket"),
      "<hr/>",
      dropdown_header("ABOUT"),
      dropdown_link("About Wikirate", "/about"),
      dropdown_link("Community", "/community"),
      dropdown_link("Data", "/data"),
      dropdown_link("Impact", "/impact")
    ]
  end

  def dropdown_link text, uri
    link_to text, path: uri, class: "dropdown-item"
  end
end
