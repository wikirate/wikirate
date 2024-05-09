require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"
Card::Auth.as_bot # needed in test env where Ethan is not a user

codename = :open_corporates
company_name = "OpenCorporates"
identifier_name = "OpenCorporates ID"

idcard = codename.card
idcard.update! name: identifier_name, skip: :update_referer_content

company = Card.create! name: company_name, type: :wikirate_company
idcard.merge_into company

Card.search type: :metric, left: codename do |metric|
  metric.update! name: [company_name, metric.name.right]
end

idcard.update! type: :corporate_identifier
