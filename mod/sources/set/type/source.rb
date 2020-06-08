require "curb"
require "link_thumbnailer"

include_set Abstract::Delist

card_accessor :metric, type_id: PointerID
card_accessor :year, type_id: PointerID
card_accessor :wikirate_topic, type_id: PointerID
card_accessor :wikirate_company, type_id: PointerID
card_accessor :wikirate_title
card_accessor :wikirate_website
card_accessor :wikirate_link, type_id: PhraseID
card_accessor :file, type_id: FileID
card_accessor :report_type, type_id: PointerID

def file_url
  file_card&.file&.url
end

def link_url
  wikirate_link_card&.content
end

format :html do
  view :unknown do
    _view_link
  end

  def icon
    "globe"
  end
end
