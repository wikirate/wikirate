include_set Abstract::CodeFile

format :html do
  view :core, template: :haml

  view :nav_bar_left do
    link_to nest(:logo, view: :core, size: :original), href: "/"
  end

  # overridden in projects site.
  view :nav_bar_middle do
    nest :navbox, view: :navbar
  end

  view :nav_bar_right, template: :haml
end
