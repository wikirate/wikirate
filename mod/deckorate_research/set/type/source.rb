require "curb"
require "link_thumbnailer"

include_set Abstract::Delist
include_set Abstract::JsonldSupport

card_accessor :metric, type: :list
card_accessor :answer, type: :search_type
card_accessor :year, type: :list
card_accessor :topic, type: :list
card_accessor :company, type: :list
card_accessor :wikirate_title, type: :phrase
card_accessor :wikirate_website, type: :phrase
card_accessor :wikirate_link, type: :phrase
card_accessor :file, type: :file
card_accessor :report_type, type: :list

def file_url
  file_card&.file&.url
end

def link_url
  wikirate_link_card&.content
end

def pod_content
  nil
end

format :html do
  view :unknown do
    _view_link
  end

  def icon
    "globe"
  end
end

format :csv do
  view :row do
    methods = %i[wikirate_title company year report_type wikirate_link]
    super() + (methods.map { |m| card.send m })
  end
end
