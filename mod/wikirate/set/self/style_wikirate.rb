include_set Abstract::CodeFile

Self::StyleMods.add_item :style_wikirate

FILE_NAMES =
  %i[top_bar
     overview_item
     company_and_topic_item
     note
     user_following_list
     wikirate_bootstrap_navbar
     wikirate_bootstrap_form
     wikirate_bootstrap_common
     company_header
     wikirate_layout
     wikirate_responsiveness
     wikirate_bootstrap_tabs
     wikirate_font_icon
     bootstrap_modal_fix
     wikirate_bootstrap_table
     wikirate_progress_bar].freeze

def source_files
  scss_files FILE_NAMES
end
