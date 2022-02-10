# for now, no notifications on acts using API key
def silent_change?
  Card::Auth.api_act? || super
end

def as_wikirate_team?
  Card::Auth.as_id == Card::WikirateTeamID
end

def as_moderator?
  Card::Auth.always_ok? || as_wikirate_team?
end
