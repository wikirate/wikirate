require "curb"
require "link_thumbnailer"

include_set Abstract::Delist

card_accessor :metric, type: PointerID
card_accessor :year, type: PointerID
card_accessor :wikirate_topic, type: PointerID
card_accessor :wikirate_company, type: PointerID
card_accessor :wikirate_title
card_accessor :wikirate_website
card_accessor :wikirate_link, type: PhraseID
card_accessor :file, type: FileID
card_accessor :report_type, type: PointerID

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
