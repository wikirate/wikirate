include_set Abstract::CodeFile

basket[:style_mods] << :style_wikirate

FILE_NAMES =
  %i[top_bar
     company_groups
     user_following_list
     wikirate_bootstrap_navbar
     wikirate_bootstrap_form
     wikirate_bootstrap_common
     wikirate_colors
     wikirate_images
     toggle_details
     company_header
     wikirate_layout
     wikirate_responsiveness
     wikirate_bootstrap_tabs
     wikirate_font_icon
     bootstrap_modal_fix
     wikirate_bootstrap_table
     wikirate_progress_bar
     bars_and_boxes].freeze

def source_files
  scss_files FILE_NAMES
end
