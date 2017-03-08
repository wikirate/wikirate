# name pattern assumed:
# [user]+[cardtype card]+badges earned

include_set Abstract::Table

attr_accessor :auto_content

def ok_to_update
  auto_content or super
end

def ok_to_create
  auto_content or super
end

def cardtype_code
  left.right.codename
end

def add_badge badge_name
  self.auto_content = true
  add_item badge_name
end

def badge_class
  @badge_class ||=
    Card::Set::Type.const_get "#{cardtype_code.to_s.camelcase}::Badges"
end

# @return badge cards in descending order and simple badges before
# affinity badges
def ordered_badge_cards
  item_cards.sort.reverse
end

format :html do
  view :core do
    wikirate_table :plain, card.ordered_badge_cards,
                   [:level, :badge, :description],
                   header: %w(Level Badge Description)
  end
end
