format :html do
  view :listing do
    haml :listing
  end

  view :expanded_listing do
    haml :expanded_listing
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
    link_to_card
  end
end