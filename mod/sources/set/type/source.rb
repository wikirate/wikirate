require "curb"

card_accessor :metric, type: :pointer
card_accessor :year, type: :pointer
card_accessor :wikirate_topic, type: :pointer
card_accessor :wikirate_company, type: :pointer
card_accessor :title
card_accessor :file


def source_title_card
  Card.fetch [name, :wikirate_title], new: {}
end

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

format :json do
  def essentials
    {
      title: card.source_title_card.content
    }
  end
end
