# name pattern assumed:
# [user]+[cardtype card]+badges earned

include_set Abstract::WikirateTable

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

def badge_class
  @badge_class ||=
    self.class.const_get "Type::#{cardtype_code.to_s.camelcase}::Badges"
end

def items
  badge_class.new(self).items
end

format :html do
  view :core do
    wikirate_table :plain, card.items, [:level, :badge, :description],
                   header: %w(Level Badge Description)
  end
end
