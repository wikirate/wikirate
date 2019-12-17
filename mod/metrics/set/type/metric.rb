require "savanna-outliers"

# include_set Abstract::Export
include_set Abstract::DesignerAndTitle
include_set Abstract::MetricThumbnail
include_set Abstract::TwoColumnLayout
include_set Abstract::BsBadge
include_set Abstract::Bookmarkable
include_set Abstract::Delist

card_accessor :metric_type, type: :pointer, default: "[[Researched]]"
card_accessor :about
card_accessor :methodology
card_accessor :value_type
card_accessor :value_options
card_accessor :report_type
card_accessor :research_policy
card_accessor :project
card_accessor :metric_answer
card_accessor :unit
card_accessor :range
card_accessor :hybrid, type: :toggle
card_accessor :question, type: :plain_text
card_accessor :score
card_accessor :wikirate_topic, type: :pointer

# METRIC-CHILD-STYLE METHODS

def metric_card
  self
end

# METRIC TYPES

def metric_type
  metric_type_card.item_names.first
end

def metric_type_codename
  Card[metric_type].codename.to_sym
end

def metric_type_id
  Card[metric_type].id
end

def value_options
  voc = value_options_card
  if voc.type_id == Card::JsonID
    voc.standard_option_names
  else
    value_options_card.item_names
  end
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

def calculated?
  !researched?
end

def researchable?
  researched? || hybrid?
end

def designer_assessed?
  research_policy.tr("[]", "").casecmp("designer assessed").zero?
end

# note: can return True for anonymous user if answer is generally researchable
def user_can_answer?
  return false unless researchable?

  # TODO: add metric designer respresentative logic here
  is_admin = Auth.always_ok?
  is_owner = Auth.current.id == creator&.id
  (is_admin || is_owner) || !designer_assessed?
end
