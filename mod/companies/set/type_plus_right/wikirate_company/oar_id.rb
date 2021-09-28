format :html do
  view :core do
    link_to card.content, href: "https://openapparel.org/facilities/#{card.content}"
  end
end
