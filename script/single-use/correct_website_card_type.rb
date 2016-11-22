require File.expand_path("../../config/environment",  __FILE__)
require File.expand_path("../wikirate_import_shared", __FILE__)

def basic_website_card
  Card.search right: "website", left: { type_id: Card::SourceID },
              type_id: Card::BasicID
end

silent_mode do
  basic_website_card.each do |website_card|
    website_card.type_id = Card::PointerID
    puts "Updating #{website_card.name}'s type to pointer".green
    website_card.save!
  end
end
