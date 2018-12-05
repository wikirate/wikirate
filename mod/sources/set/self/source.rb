
def self.find_duplicates url
  Card.search type_id: Card::SourceID,
              right_plus: [Card::WikirateLinkID, { content: url }]
end

format :html do
  view :core, template: :haml
end
