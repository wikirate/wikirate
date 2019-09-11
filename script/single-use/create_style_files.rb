names = %w[style_top_bar style_slick style_overview_item style_company_and_topic_item
           style_homepage_layout style_note style_user_following_list
           style_wikirate_bootstrap_navbar style_profile_page style_company_header
           style_wikirate_layout style_wikirate_responsiveness
           style_fakeloader style_wikirate_font_icon style_bootstrap_modal_fix]

names.each do |name|
  system "bundle exec rake wikirate:add:stylesheet mod=wikirate name=#{name}"
end
