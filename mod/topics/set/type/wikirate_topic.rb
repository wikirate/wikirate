include_set Abstract::TwoColumnLayout
include_set Abstract::Thumbnail
include_set Abstract::FilterableBar
include_set Abstract::Bookmarkable
include_set Abstract::Delist

card_accessor :image, type_id: ImageID
card_accessor :subtopic, type_id: PointerID
card_accessor :supertopic, type_id: SearchTypeID
# card_accessor :wikirate_company
card_accessor :metric
