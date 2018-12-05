require "curb"
require "link_thumbnailer"

card_accessor :metric, type: :pointer
card_accessor :year, type: :pointer
card_accessor :wikirate_topic, type: :pointer
card_accessor :wikirate_company, type: :pointer
card_accessor :wikirate_title
card_accessor :wikirate_link
card_accessor :file

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
  view :content do
    add_name_context
    super()
  end

  view :missing do
    _view_link
  end

  def icon
    "globe"
  end
end
