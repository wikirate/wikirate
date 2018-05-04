include_set Abstract::CodePointer
Self::StyleMods.add_to_basket :item_codenames, :style_wikirate

FILE_NAMES =
  %i[
     top_bar
     slick
     overview_item
     company_and_topic_item
     homepage_layout
     note
     user_following_list
     wikirate_bootstrap_navbar
     wikirate_bootstrap_form
     wikirate_bootstrap_common

     profile_page
     company_header
     source_preview
     wikirate_layout
     wikirate_responsiveness
     wikirate_bootstrap_tabs
     fakeloader
     wikirate_font_icon
     bootstrap_modal_fix
     wikirate_bootstrap_table
     wikirate_progress_bar
     filter
     project
     badges
     browse_items
     research
  ].freeze

def source_files
  scss_files FILE_NAMES
end
