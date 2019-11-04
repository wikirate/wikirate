# couldn't get this to work by adding it to abstract metric answer :(
include_set Abstract::DesignerPermissions

# this has to be on a type set for field events to work
require_field :value, when: :value_required?
require_field :source, when: :source_required?

def value_required?
  metric_card&.respond_to?(:value_required?) ? metric_card.value_required? : true
end