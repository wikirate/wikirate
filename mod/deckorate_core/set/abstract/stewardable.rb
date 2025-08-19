card_accessor :steward, type: :pointer

def stewarded_card
  self
end

def steward_assessed?
  research_policy&.casecmp("steward assessed")&.zero?
end

def ok_as_steward?
  steward_assessed? ? steward? : true
end

def ok_to_update?
  steward?
end

def ok_to_delete?
  steward?
end

def steward?
  Auth.as_id.in?(steward_ids) || Auth.always_ok?
end

def steward_ids
  @steward_ids ||= steward_id_lists.flatten.compact.uniq
end

private

def steward_id_lists
  [Self::Steward.always_ids, steward_card&.item_ids, creator_steward_id]
end

# HACK.  our verification testing assumed that DeckoBot was not a steward.
# So adding the creator_id to the steward list broke a bunch of verification tests
# When there's time, we should update the tests and get rid of this. --efm
def creator_steward_id
  creator_id unless creator_id == Card::DeckoBotID
end
