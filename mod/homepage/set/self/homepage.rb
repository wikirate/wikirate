include_set Abstract::SolidCache, cached_format: :html

cache_expire_trigger Card::Set::All::ActiveCard do |_changed_card|
  Card[:homepage]
end

format :html do
  view :core do
    output [
      render_wikirate_modal,
      nest(:homepage_top_banner),
      nest(:homepage_video_section),
      nest(:homepage_numbers),
      nest(:homepage_projects),
      nest(:homepage_topics),
      nest(:homepage_organizations),
      nest(:homepage_footer)
    ]
  end

  def edit_fields
    [[:homepage_introductions, { absolute: true }],
     [:homepage_communities, { absolute: true }]]
  end
end
