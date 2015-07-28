require File.expand_path('../../config/environment',  __FILE__)

Card::Auth.as_bot do
  value_in_basic_type = Card.search(:left=>{:type_id=>Card::MetricValueID},:right=>{:name=>"value",:type_id=>Card::BasicID})
  value_in_basic_type.each do |card|
    puts card.name
    card.type_id = Card::PhraseID
    card.save!
  end
end