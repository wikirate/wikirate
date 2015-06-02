require File.expand_path('../../config/environment',  __FILE__)


Card::Auth.as_bot do
  plus_sources = Card.search :type_id=>Card::PointerID,:right=>Card[:source].name, :not=>{:refer_to=>{:type_id=>Card::SourceID}}
  puts plus_sources.size
  plus_sources.each do |plus_source_card|
    puts plus_source_card.name
    plus_source_card.update_references
  end
end