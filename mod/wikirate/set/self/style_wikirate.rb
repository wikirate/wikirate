include_set Abstract::CodeFile

add_to_codepointer Self::StyleMods, :style_wikirate
# if Card::Codename.exist? :style_wikirate
#   Self::StyleMods.add_to_basket :item_codenames, :style_wikirate
# end

FILE_NAMES =
  %i[
     top_bar
     overview_item
     company_and_topic_item
     note
     user_following_list
     wikirate_bootstrap_navbar
     wikirate_bootstrap_form
     wikirate_bootstrap_common
     profile_page
     company_header
     wikirate_layout
     wikirate_responsiveness
     wikirate_bootstrap_tabs
     wikirate_font_icon
     bootstrap_modal_fix
     wikirate_bootstrap_table
     wikirate_progress_bar
     filter
     project
     badges
     browse_items
  ].freeze

def source_files
  scss_files FILE_NAMES
end
