
def self.find_duplicates url
  duplicate_wql = { right: Card[:wikirate_link].name, content: url,
                    left: { type_id: Card::SourceID } }
  Card.search duplicate_wql
end

format :html do
  view :core, template: :haml
end
