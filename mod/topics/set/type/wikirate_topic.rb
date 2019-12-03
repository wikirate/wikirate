# include_set Abstract::WikirateTable
# include_set Abstract::Media
# include_set Abstract::BsBadge
include_set Abstract::TwoColumnLayout
include_set Abstract::Thumbnail
include_set Abstract::FilterableBar
include_set Abstract::Bookmarkable

card_accessor :image, type: :image
card_accessor :subtopic, type: :pointer
card_accessor :supertopic, type: :search_type
# card_accessor :wikirate_company
card_accessor :metric
