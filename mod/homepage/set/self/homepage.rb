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
      nest(:homepage_footer, view: :core)
    ]
  end

  def edit_fields
    [[:homepage_solution_text, { absolute: true }],
     [:homepage_project_text, { absolute: true }],
     [:homepage_topic_text, { absolute: true }],
     [:homepage_featured_companies, { absolute: true }],
     [:homepage_featured_topics, { absolute: true }],
     [:homepage_adjectives, { absolute: true }],
     [:homepage_featured_projects, { absolute: true }],
     [:homepage_featured_answers, { absolute: true }],
     [:organizations_using_wikirate, { absolute: true }],
     [:menu_explore, { absolute: true }],
     [:menu_about, { absolute: true }],
     [:menu_connect, { absolute: true }],
     [:menu_legal, { absolute: true }]]
  end
end
