include_set Abstract::CodeFile
basket[:style_mods] << :style_homepage

FILE_NAMES = %i[homepage].freeze

def source_files
  scss_files FILE_NAMES
end
