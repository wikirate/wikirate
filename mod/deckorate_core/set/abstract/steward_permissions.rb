# eg include_set Abstract::StewardPermissions
#
# Cards with this set must respond to #stewarded_card.
#
# If the card is "steward assessed", then cards with this set can only be edited by
# a steward

# can be overwritten
def stewarded_card
  left
end

def stewarded_type
  stewarded_card.type_name
end

def ok_to_create?
  super && check_steward_permissions(:create)
end

def ok_to_update?
  super && check_steward_permissions(:update)
end

def ok_to_delete?
  stewarded_card&.steward?
end

private

def check_steward_permissions action
  return true if !stewarded_card || stewarded_card.ok_as_steward?

  deny_because "Only stewards can #{action} this on steward-assessed #{stewarded_type}s"
end
