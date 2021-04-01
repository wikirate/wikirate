NAV_MENU_HR_AFTER = { "Metrics" => true,
                      "Advanced" => true,
                      "Programs" => true }

format :html do
  view :core do
    haml :nav_menu, hr_after: NAV_MENU_HR_AFTER
  end
end
