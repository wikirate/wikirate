include_set Abstract::Media
include_set Abstract::Table

format :html do
  view :bar_left, template: :haml

  # TODO: make an Abstract Library for handling these fancy company and metric thumbnails
  # (Eg we need them on Answer searches)
  view :company_thumbnail, unknown: true do
    args = { view: :thumbnail, hide: :thumbnail_link, show: [] }
    %i[headquarters identifiers_list].each do |view|
      args[:show] << view if voo.explicit_show? view
    end
    nest card.company, args
  end

  view :credit do
    wrap_with :small do
      nest card.value_card, view: :credit
    end
  end
end
