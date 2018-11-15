require "curb"

card_accessor :metric, type: :pointer
card_accessor :year, type: :pointer
card_accessor :wikirate_topic, type: :pointer
card_accessor :wikirate_company, type: :pointer
card_accessor :wikirate_title
card_accessor :wikirate_link
card_accessor :file

require "link_thumbnailer"

def file_url
  file_card&.file&.url
end

def link_url
  wikirate_link_card&.content
end

def link?
  wikirate_link_card.present?
end

format :html do
  def icon
    "globe"
  end
end