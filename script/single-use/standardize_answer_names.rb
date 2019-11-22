require File.expand_path "../../../config/environment", __FILE__

Card::Auth.current_id = Card.fetch_id "Ethan McCutchen"

Card.where(type_id: Card::MetricAnswerID).find_each do |answer|
  standard = answer.name.standard

  next if answer.name.to_s == standard.to_s

  answer.update_column :name, standard
end
