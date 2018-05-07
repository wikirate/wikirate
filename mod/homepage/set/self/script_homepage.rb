include_set Abstract::CodeFile
Self::ScriptMods.add_item :script_homepage

FILE_NAMES = %i[homepage_carousel].freeze

def source_files
  coffee_files FILE_NAMES
end
