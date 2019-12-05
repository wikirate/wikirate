require File.expand_path "../../../config/environment", __FILE__

Card::Auth.current_id = Card.fetch_id "Ethan McCutchen"

Card.where(type_id: Card::MetricAnswerID).find_each do |answer|
  standard = answer.name.standard

  if answer.name.to_s != standard.to_s
    answer.update_column :name, standard
  end
end

structured_ids = %i[
  wikirate_company metric_title wikirate_topic metric metric_answer project
].map { |code| Card.fetch_id code }

structured_ids << Card.fetch_id("Ticket")

Card.where("type_id in (#{structured_ids * ', '})").update_all(db_content: "")
