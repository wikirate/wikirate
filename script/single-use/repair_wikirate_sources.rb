require File.expand_path "../../../config/environment", __FILE__

Card::Auth.current_id = Card.fetch_id "Ethan McCutchen"

SOURCE_HASH = {
  "Source_000090797" => "Source_000090794",
  "Source_000090796" => "Source_000057963",
  "Source_000090795" => "Source_000090791",
  "Source_000090790" => "Source_000059522",
  "Source_000090789" => "Source_000063742"
}

SOURCE_HASH.each do |bad_name, good_name|
  Card.search right: Card::SourceID, refer_to: bad_name do |citation|
    citation.drop_item bad_name
    citation.add_item good_name
    citation.save!
  end
  Card[bad_name]&.delete!
end
