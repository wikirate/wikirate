require "curb"
require "link_thumbnailer"

card_accessor :metric, type: :pointer
card_accessor :year, type: :pointer
card_accessor :wikirate_topic, type: :pointer
card_accessor :wikirate_company, type: :pointer
card_accessor :wikirate_title
card_accessor :wikirate_website
card_accessor :wikirate_link, type: :phrase
card_accessor :file, type: :file
card_accessor :report_type, type: :pointer

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
