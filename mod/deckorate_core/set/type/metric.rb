# require "savanna-outliers"

include_set Abstract::Thumbnail
include_set Abstract::DeckorateTabbed
include_set Abstract::BsBadge
include_set Abstract::Bookmarkable
include_set Abstract::Delist
include_set Abstract::Lookup
include_set Abstract::Publishable

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
card_accessor :steward, type: :pointer
card_accessor :topic, type: :list
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

def ok_to_update?
  steward?
end

def ok_to_delete?
  steward?
end

def user_can_answer?
  Auth.signed_in? && researchable? && ok_as_steward?
end
