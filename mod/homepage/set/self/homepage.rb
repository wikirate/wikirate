include_set Abstract::SolidCache, cached_format: :html

cache_expire_trigger Card::Set::All::ActiveCard do |_changed_card|
  Card[:homepage]
end

format :html do
  view :cacheable_core do
    binding.pry
    output [
      render_wikirate_modal,
      nest(:homepage_top_banner),
      nest(:homepage_introductions),
      nest(:homepage_communities)
    ]
  end

  def edit_fields
    [[:homepage_introductions, { absolute: true }],
     [:homepage_communities, { absolute: true }]]
  end
end
