include_set Abstract::CodeFile
Self::ScriptMods.add_to_basket :item_codenames, :script_source

FILE_NAMES =
  %w[
    new_source_page
    source_preview
  ].freeze

def source_files
  coffee_files FILE_NAMES
end
