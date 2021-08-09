include_set Abstract::CodeFile
basket[:style_mods] << :style_source

FILE_NAMES = %i[source_preview].freeze

def source_files
  scss_files FILE_NAMES
end
