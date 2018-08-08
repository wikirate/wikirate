include_set Abstract::SolidCache, cached_format: :html

cache_expire_trigger Card::Set::All::ActiveCard do |_changed_card|
  Card[:homepage]
end

format :html do
  view :core do
    output [
      render_wikirate_modal,
      nest(:homepage_top_banner, view: :core),
      nest(:homepage_video_section, view: :core),
      nest(:homepage_numbers, view: :core),
      nest(:homepage_projects, view: :core),
      nest(:homepage_topics, view: :core),
      nest(:homepage_organizations, view: :core),
      nest(:newsletter_signup, view: :core),
      nest(:homepage_footer, view: :core)
    ]
  end

  def edit_fields
    [[:featured_companies, { absolute: true }],
     [:featured_topics, { absolute: true }],
     [:homepage_adjectives, { absolute: true }],
     [:featured_projects, { absolute: true }],
     [:featured_answers, { absolute: true }]]
  end
end
