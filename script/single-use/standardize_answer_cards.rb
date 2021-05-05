require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

# correct answer names (eg by removing underscores)
Card.where(type_id: Card::MetricAnswerID).find_each do |answer|
  standard = answer.name.standard

  if answer.name.to_s != standard.to_s
    answer.update_column :name, standard
  end
end

# get rid of structured content in structured cards (because most of it is old or
# nonsense, and it includes a lot of errors)
structured_ids = %i[
  wikirate_company metric_title wikirate_topic metric metric_answer project
].map { |code| code.card_id }

structured_ids << "Ticket".card_id

Card.where("type_id in (#{structured_ids * ', '})").update_all(db_content: "")
