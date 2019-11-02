# couldn't get this to work by adding it to abstract metric answer :(
include_set Abstract::DesignerPermissions

# this has to be on a type set for field events to work
require_field :value
require_field :source, when: :source_required?
