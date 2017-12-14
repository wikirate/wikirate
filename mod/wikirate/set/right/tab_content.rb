include_set Abstract::WikirateTabs

format :html do
  view :core, cache: :never do
    tab_content
  end
end
