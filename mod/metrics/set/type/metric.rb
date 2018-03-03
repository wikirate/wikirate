require "savanna-outliers"

include_set Abstract::Export
include_set Abstract::DesignerAndTitle
include_set Abstract::MetricThumbnail

card_accessor :vote_count, type: :number, default: "0"
card_accessor :upvote_count, type: :number, default: "0"
card_accessor :downvote_count, type: :number, default: "0"

card_accessor :metric_type, type: :pointer, default: "[[Researched]]"
card_accessor :about
card_accessor :methodology
card_accessor :value_type
card_accessor :value_options
card_accessor :report_type
card_accessor :research_policy
card_accessor :project
card_accessor :all_metric_values
card_accessor :unit
card_accessor :range
card_accessor :currency
card_accessor :hybrid, type: :toggle
card_accessor :question

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

# these methods are overridden in at least one metric type
def self.default_false method_name
  define_method(method_name) { false }
end

default_false :relationship?
default_false :inverse?
default_false :standard?
default_false :researched?
default_false :hybrid?
default_false :rating?
default_false :ten_scale?
default_false :score?

def calculated?
  !researched?
end

# RESEARCH POLICY

def designer_assessed?
  research_policy.casecmp("designer assessed").zero?
end

event :silence_metric_deletions, :initialize, on: :delete do
  @silent_change = true
end
