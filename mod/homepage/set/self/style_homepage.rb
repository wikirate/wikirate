include_set Abstract::CodePointer
Self::StyleMods.add_item :style_homepage

FILE_NAMES = %i[homepage].freeze

def source_files
  scss_files FILE_NAMES
end
