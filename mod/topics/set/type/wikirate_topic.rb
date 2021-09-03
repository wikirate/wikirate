include_set Abstract::TwoColumnLayout
include_set Abstract::Thumbnail
include_set Abstract::FilterableBar
include_set Abstract::Bookmarkable
include_set Abstract::Delist
include_set Abstract::CachedTypeOptions

card_accessor :image, type: ImageID
card_accessor :subtopic, type: PointerID
card_accessor :supertopic, type: SearchTypeID
card_accessor :dataset
# card_accessor :wikirate_company
card_accessor :metric
