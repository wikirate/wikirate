# name pattern assumed:
# [user]+[cardtype card]+badges earned

include_set Abstract::Table
include_set Abstract::Certificate
include_set Abstract::Paging

attr_accessor :auto_content

def ok_to_update
  auto_content || super
end

def ok_to_create
  auto_content || super
end

def cardtype_code
  left.right.codename
end

def add_badge_card badge_card
  self.auto_content = true
  return if include_item? badge_card
  success.flash badge_card.flash_message
  index = bsearch_index(badge_card)
  # update_attributes content: item_names.insert(index, badge_card.name).to_pointer_content
  self.content = item_names.insert(index, badge_card.name).to_pointer_content
end

# used for award_badges migration
# assumes that all elements in badge_names are of the same level
# so that they belong in the same spot
def add_batch_of_badges badge_names
  self.auto_content = true
  sample_badge_card = Card.fetch badge_names.first
  # for performance reason we check only one card
  # and assume the whole batch has already been added if it's already there
  return if include_item? sample_badge_card
  index = bsearch_index(sample_badge_card)
  self.content = item_names.insert(index, badge_names)
                           .flatten.to_pointer_content
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
    next unless badge.respond_to?(:badge_level)
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

  def limit
    20
  end

  view :core do
    with_paging do
      wikirate_table :plain, card.item_cards(limit: limit, offset: offset),
                     [:level, :badge, :description],
                     header: %w[Level Badge Description],
                     td: { classes: ["badge-certificate", nil, nil] }
    end
  end
end
