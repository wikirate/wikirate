require File.expand_path("../../config/environment",  __FILE__)

Card::Auth.as_bot do
  plus_sources = Card.search type_id: Card::PointerID, right: Card[:source].name,
                             not: { refer_to: { type_id: Card::SourceID } }
  puts plus_sources.size
  plus_sources.each do |plus_source_card|
    puts "updating reference of #{plus_source_card.name}".green
    plus_source_card.update_references_out
  end
  notes = Card.search type_id: Card::ClaimID
  notes.each do |note|
    puts "updating reference of #{note.name}".green
    note.update_references_out
  end
end
