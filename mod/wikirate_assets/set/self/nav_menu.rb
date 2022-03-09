NAV_MENU_HR_AFTER = { "Metrics" => true,
                      "Advanced" => true,
                      "Programs" => true }.freeze

format :html do
  view :core do
    haml :nav_menu
  end

  def nav_item menu, remote: false
    haml :nav_item, hr_after: NAV_MENU_HR_AFTER,
                    menu: menu,
                    items: nav_menus[menu],
                    remote: remote
  end
end
