def virtual?
  new?
end

def user_acts
  Card::Act.where(actor_id: left.id).where.not(card_id: nil).order("acted_at desc")
end

def accounted?
  left&.account?
end

format :html do
  view :core, cache: :never do
    acts_layout card.user_acts, :absolute
  end

  view :open do
    card.accounted? ? super() : ""
  end
end
