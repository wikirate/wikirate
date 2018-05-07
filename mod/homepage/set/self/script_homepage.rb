include_set Abstract::CodePointer
Self::ScriptMods.add_to_basket :item_codenames, :script_homepage

FILE_NAMES = %i[homepage_carousel].freeze

def source_files
  coffee_files FILE_NAMES
end