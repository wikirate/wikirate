require "curb"
require "link_thumbnailer"

include_set Abstract::Delist

card_accessor :metric, type: :list
card_accessor :metric_answer, type: :search_type
card_accessor :year, type: :list
card_accessor :wikirate_topic, type: :list
card_accessor :wikirate_company, type: :list
card_accessor :wikirate_title, type: :phrase
card_accessor :wikirate_website, type: :phrase
card_accessor :wikirate_link, type: :phrase
card_accessor :file, type: :file
card_accessor :report_type, type: :pointer

def file_url
  file_card&.file&.url
end

def link_url
  wikirate_link_card&.content
end

def export_content
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
