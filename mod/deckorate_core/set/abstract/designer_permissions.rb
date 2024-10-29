# eg include_set Abstract::DesignerPermissions
#
# Cards with this set must respond to #metric_card.
#
# If the metric is "designer assessed", then cards with this set can only be edited by
# the designer (or members of the Wikirate team)

def ok_to_create?
  super && check_designer_permissions(:create)
end

def ok_to_update?
  super && check_designer_permissions(:update)
end

def ok_to_delete?
  metric_card&.steward?
end

private

def check_designer_permissions action
  return true if !metric_card || metric_card.ok_as_steward?

  deny_because "Only metric stewards can #{action} this on designer-assessed metrics"
end
