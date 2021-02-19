def virtual?
  new?
end

def user_acts
  Card::Act.where "actor_id=#{left.id} and card_id is not NULL"
end

def accounted?
  left&.account
end

format :html do
  view :core do
    acts_layout card.user_acts, :absolute
  end

  view :open do
    card.accounted? ? super() : ""
  end
end
