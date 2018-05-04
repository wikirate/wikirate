include_set Abstract::CodePointer
Self::StyleMods.add_to_basket :item_codenames, :style_homepage

FILE_NAMES =
  %i[slick homepage].freeze

def source_files
  scss_files FILE_NAMES
end
