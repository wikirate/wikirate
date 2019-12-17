require File.expand_path "../../../config/environment", __FILE__

Card::Auth.current_id = Card.fetch_id "Ethan McCutchen"

SOURCE_HASH = {
  "Source_000090788" => "Source_000065679",
  "Source_000090787" => "Source_000063732",
  "Source_000090786" => "Source_000065342",
  "Source_000090785" => "Source_000065654",
  "Source_000090784" => "Source_000059918",
  "Source_000090783" => "Source_000059530",
  "Source_000090782" => "Source_000065678",
  "Source_000090781" => "Source_000065657",
  "Source_000090780" => "Source_000065677",
  "Source_000090779" => "Source_000059933",
  "Source_000090778" => "Source_000058029",
  "Source_000090777" => "Source_000059925",
  "Source_000090776" => "Source_000061340",
  "Source_000090775" => "Source_000087136",
  "Source_000090774" => "Source_000087133",
  "Source_000090773" => "Source_000065674",
  "Source_000090772" => "Source_000063928",
  "Source_000090771" => "Source_000065675",
  "Source_000090770" => "Source_000087140",
  "Source_000090769" => "Source_000059948",
  "Source_000090768" => "Source_000061266",
  "Source_000090767" => "Source_000059515",
  "Source_000090766" => "Source_000065361",
  "Source_000089877" => "Source_000089879",
  "Source_000089592" => "Source_000089146",
  "Source_000089332" => "Source_000088882",
  "Source_000088299" => "Source_000088298",
  "Source_000085975" => "Source_000082426"
}

SOURCE_HASH.each do |bad_name, good_name|
  Card.search right: Card::SourceID, refer_to: bad_name do |citation|
    citation.drop_item bad_name
    citation.add_item good_name
    citation.save!
  end
  Card[bad_name]&.delete!
end
