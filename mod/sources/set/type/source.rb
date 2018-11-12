require "curb"

card_accessor :metric, type: :pointer
card_accessor :year, type: :pointer
card_accessor :wikirate_topic, type: :pointer
card_accessor :wikirate_company, type: :pointer
card_accessor :title
card_accessor :file

add_attributes :import
attr_accessor :import

def source_title_card
  Card.fetch [name, :wikirate_title], new: {}
end

def import?
  # default (=nil) means true
  @import != false && Cardio.config.x.import_sources
end

require "link_thumbnailer"

def link_card
  fetch trait: :wikirate_link
end

def file_url
  file_card&.attachment&.url
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
