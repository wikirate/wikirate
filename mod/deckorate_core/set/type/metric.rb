# require "savanna-outliers"

include_set Abstract::Thumbnail
include_set Abstract::DeckorateTabbed
include_set Abstract::BsBadge
include_set Abstract::Bookmarkable
include_set Abstract::Delist
include_set Abstract::Lookup
include_set Abstract::Publishable
include_set Abstract::Stewardable

card_accessor :metric_type, type: :pointer, default_content: "Researched"
card_accessor :about
card_accessor :methodology
card_accessor :value_type, type: :pointer
card_accessor :value_options, type: :list
card_accessor :dataset, type: :search_type
card_accessor :answer, type: :search_type
card_accessor :unit, type: :phrase
card_accessor :range, type: :phrase
card_accessor :hybrid, type: :toggle
card_accessor :question, type: :plain_text
card_accessor :report_type, type: :list
card_accessor :score, type: :search_type
card_accessor :topic, type: :list
card_accessor :topic_framework, type: :list
card_accessor :research_policy, type: :pointer, default_content: "Community Assessed"
card_accessor :relationship, type: :search_type
card_accessor :company, type: :search_type

# applicability
card_accessor :year, type: :list
card_accessor :company_group, type: :list

# TODO: make this work (was breaking seeding)
# require_field :metric_type

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
  metric_type.codename
end

def metric_type_id
  metric_type.card_id
end

def metric_type_name
  metric_type_id.cardname
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

default_false :relation?
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

# calculated metric types that can use this metric as a variable
# overridden elsewhere; eg you don't score a score
def calculation_types
  %i[score formula descendant]
end

def calculated?
  !researched?
end
