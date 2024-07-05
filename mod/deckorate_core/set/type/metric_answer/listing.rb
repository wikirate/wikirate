include_set Abstract::Media
include_set Abstract::Table

format :html do
  view :bar_left, template: :haml

  view :company_thumbnail, unknown: true do
    company_thumbnail card.company, hide: :thumbnail_link
  end

  view :credit do
    wrap_with :small do
      nest card.value_card, view: :credit
    end
  end
end
