NAV_MENUS = {
  "Explore" => %w[Companies Topics Metrics Projects Groups Sources Changes],
  "Research" => ["Add Data", "Use Data", "Organize Projects", "FAQ", "Report Issue"],
  "Org" => ["About the Project", "Our Team", "Programs", "Publications", "News",
              "Contact Us", "Donate"]
}.freeze

NAV_MENU_CARDNAMES = { "Groups" => "Research Groups",
                       "Changes" => ":recent",
                       "FAQ" => "Frequently Asked Questions",
                       "Report Issue" => "Tickets" }.freeze

NAV_MENU_HR_AFTER = { "Metrics" => true }

format :html do
  view :core do
    haml :nav_menu, nav_menus: NAV_MENUS, hr_after: NAV_MENU_HR_AFTER
  end

  def nav_menu_item_url menu, item_name
    cardname = NAV_MENU_CARDNAMES[item_name] || item_name
    url_prefix(menu) + cardname.to_name.url_key
  end

  def url_prefix menu
    menu == "Org" ? "https://project.wikirate.org/" : "/"
  end
end
