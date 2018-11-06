require "curb"

card_accessor :metric, type: :pointer
card_accessor :year, type: :pointer
card_accessor :source_type, type: :pointer, default: "[[Link]]"
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

def source_type_codename
  source_type_card.item_cards[0].codename.to_sym
end

def wikirate_link?
  source_type_codename == :wikirate_link
end

format :html do
  def icon
    "globe"
  end
end

format :json do
  def essentials
    {
      type: card.source_type_card.item_names.first,
      title: card.source_title_card.content
    }
  end
end
