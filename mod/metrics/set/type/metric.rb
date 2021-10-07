require "savanna-outliers"

include_set Abstract::DesignerAndTitle
include_set Abstract::MetricThumbnail
include_set Abstract::TwoColumnLayout
include_set Abstract::BsBadge
include_set Abstract::Bookmarkable
include_set Abstract::Delist
include_set Abstract::Lookup
include_set Abstract::Publishable

card_accessor :metric_type, type: PointerID, default: "[[Researched]]"
card_accessor :about
card_accessor :methodology
card_accessor :value_type
card_accessor :value_options
card_accessor :dataset
card_accessor :metric_answer
card_accessor :unit
card_accessor :range
card_accessor :hybrid, type: ToggleID
card_accessor :question, type: PlainTextID
card_accessor :report_type, type: PointerID
card_accessor :score, type: PointerID
card_accessor :steward, type: PointerID
card_accessor :wikirate_topic, type: ListID
card_accessor :research_policy, type: PointerID
card_accessor :relationship_answer

# applicability
card_accessor :year, type: ListID
card_accessor :company_group, type: ListID

def lookup_class
  ::Metric
end

def scorer_id
  nil
end

# METRIC-CHILD-STYLE METHODS

def metric_card
  self
end

# METRIC TYPES

def metric_type
  metric_type_card.first_name
end

def metric_type_codename
  Card[metric_type].codename.to_sym
end

def metric_type_id
  Card[metric_type].id
end

def value_options
  voc = value_options_card
  voc.send "item_#{voc.type_id == JsonID ? :values : :names}"
end

def value_option_names
  value_options_card.item_names
end

# these methods are overridden in at least one metric type
def self.default_false method_name
  define_method(method_name) { false }
end

default_false :relationship?
default_false :inverse?
default_false :standard?
default_false :researched?
default_false :hybrid?
default_false :ten_scale?
default_false :descendant?
default_false :score?
default_false :rating?

def value_required?
  true
end

def calculated?
  !researched?
end

def researchable?
  researched? || hybrid?
end

def designer_assessed?
  research_policy&.casecmp("designer assessed")&.zero?
end

def steward?
  Auth.as_id.in?(steward_ids) || Auth.always_ok?
end

def designer?
  Auth.as_id == metric_designer_id
end

def steward_ids
  @steward_ids ||= [
    Self::Steward.always_ids,
    steward_card&.item_ids,
    metric_designer_id,
    creator_steward_id
  ].flatten.compact.uniq
end

# HACK.  our verification testing assumed that DeckoBot was not a steward.
# So adding the creator_id to the steward list broke a bunch of verification tests
# When there's time, we should update the tests and get rid of this. --efm
def creator_steward_id
  creator_id unless creator_id == Card::WagnBotID
end

def ok_as_steward?
  designer_assessed? ? steward? : true
end

def user_can_answer?
  Auth.signed_in? && researchable? && ok_as_steward?
end
