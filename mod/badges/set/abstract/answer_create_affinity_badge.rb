# abstract set used for affinity badges like
# [Designer]+Researcher+designer_badge or
# [Company]+Research Engine+company_badge

include_set Abstract::AnswerCreateBadge

def virtual?
  true
end

format :html do
  delegate :affinity, :affinity_card, to: :card

  view :badge do
    nest affinity_card, view: :thumbnail
  end
end

def badge_key
  self[1].codename.to_sym
end

def affinity
  cardname.parts[0]
end

def affinity_card
  self[0]
end
