# name pattern assumed:
# [user]+[cardtype card]+badges earned

include_set Abstract::Table
include_set Abstract::Certificate

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

def add_badge_card badge_card
  self.auto_content = true
  return if include_item? badge_card
  index = bsearch_index(badge_card)
  self.content = item_names.insert(index, badge_card.name).to_pointer_content
end

def bsearch_index badge_card
  # ruby 2.3 has bsearch_index
  items = item_cards
  return 0 if items.empty?
  el = items.bsearch { |x| x < badge_card }
  el ? items.index(el) : items.size
end

def badge_class
  @badge_class ||=
    Card::Set::Type.const_get "#{cardtype_code.to_s.camelcase}::Badges"
end

def badge_count level=nil
  return item_names.count unless level
  item_cards.count do |badge|
    badge.badge_level == level
  end
end

# @return badge cards in descending order and simple badges before
# affinity badges
def ordered_badge_cards
  item_cards.sort.reverse
end

format :html do
  delegate :badge_count, to: :card


  view :core do
    wikirate_table :plain, card.item_cards,
                   [:level, :badge, :description],
                   header: %w(Level Badge Description),
                   td: { classes: ["badge-certificate", nil, nil] }
  end
end
