include_set Abstract::Media
include_set Abstract::Table

format :html do
  view :bar_left, template: :haml

  view :company_thumbnail do
    company_thumbnail card.company, hide: :thumbnail_link
  end
end
