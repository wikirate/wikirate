include_set Abstract::DeckorateTabbed
include_set Abstract::Thumbnail
include_set Abstract::Bookmarkable
include_set Abstract::Delist
include_set Abstract::CachedTypeOptions

card_accessor :image, type: :image
card_accessor :subtopic, type: :pointer
card_accessor :supertopic, type: :search_type
card_accessor :dataset, type: :search_type
# card_accessor :wikirate_company
card_accessor :metric, type: :search_typ
