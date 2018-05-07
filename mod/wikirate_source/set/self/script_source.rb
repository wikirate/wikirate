include_set Abstract::CodeFile
Self::ScriptMods.add_item :script_source

FILE_NAMES =
  %w[
    new_source_page
    source_preview
  ].freeze

def source_files
  coffee_files FILE_NAMES
end
