include_set Abstract::CodeFile
Self::ScriptMods.add_item :script_wikirate

FILE_NAMES =
  %w[new_note_page
     overview_page
     import_page
     showcase
     company_page
     collapse
     general_popup
     activate_readmore
     suggested_source
     empty_tab_content
     note_citation
     wikirate_coffee].freeze

def source_files
  coffee_files FILE_NAMES
end
