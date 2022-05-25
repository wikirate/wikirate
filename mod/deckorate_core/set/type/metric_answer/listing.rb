include_set Abstract::Media
include_set Abstract::Table

format :html do
  view :bar_left, template: :haml

  view :company_thumbnail do
    company_thumbnail card.company, hide: :thumbnail_link
  end

  view :company_thumbnail_with_bookmark do
    nest card.company_card, view: :thumbnail_with_bookmark, hide: :thumbnail_link
  end
end
