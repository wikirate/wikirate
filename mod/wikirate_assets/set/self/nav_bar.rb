include_set Abstract::CodeFile

format :html do
  view :raw, template: :haml

  # overridden in projects site.
  view :nav_bar_middle do
    nest :navbox, view: :navbar
  end

  view :nav_bar_right, template: :haml
end
