require "curb"

card_accessor :metric, type: :pointer
card_accessor :year, type: :pointer
card_accessor :source_type, type: :pointer, default: "[[Link]]"
card_accessor :wikirate_topic, type: :pointer
card_accessor :wikirate_company, type: :pointer
card_accessor :title

add_attributes :import
attr_accessor :import

def icon
  "globe"
end

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

# TODO: move this wql to a +metric card and cache the counts.
def related_metric_wql
  { type_id: Card::MetricID,
    right_plus: [{ type_id: Card::WikirateCompanyID },
                 { right_plus: [{ type: "year" },
                                { right_plus: ["source", { link_to: card.name }] }] }] }
end

def metric_count
  Card.search related_metric_wql.merge(return: :count)
end

format :json do
  def essentials
    {
      type: card.source_type_card.item_names.first,
      title: card.source_title_card.content
    }
  end
end
