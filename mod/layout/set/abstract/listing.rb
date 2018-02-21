format :html do
  view :listing do
    wrap { haml :listing }
  end

  view :expanded_listing do
    wrap { haml :expanded_listing }
  end

  view :listing_left do
    "override listing_left view"
  end

  view :listing_right do
    "override listing_right view"
  end

  view :listing_middle do
    "override listing_middle view"
  end

  view :listing_bottom do
    "override listing_bottom view"
  end

  view :listing_page_link do
    link_to_card card, icon_tag(:open_in_new)
  end

  view :listing_expand_link do
    link_to_view :expanded_listing, icon_tag(:play_arrow), class: "slotter"
  end

  view :listing_collapse_link do
    link_to_view :listing, icon_tag(:arrow_drop_down), class: "slotter"
  end
end
