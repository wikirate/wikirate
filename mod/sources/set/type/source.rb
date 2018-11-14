require "curb"

card_accessor :metric, type: :pointer
card_accessor :year, type: :pointer
card_accessor :wikirate_topic, type: :pointer
card_accessor :wikirate_company, type: :pointer
card_accessor :wikirate_title
card_accessor :file

require "link_thumbnailer"

def link_card
  fetch trait: :wikirate_link
end

def file_url
  file_card&.file&.url
end

def link?
  link_card.present?
end

format :html do
  def icon
    "globe"
  end
end