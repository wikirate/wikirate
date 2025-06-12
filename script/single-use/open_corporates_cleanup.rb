require File.expand_path "../../script_helper.rb", __FILE__

codename = :open_corporates
company_name = "OpenCorporates"
identifier_name = "OpenCorporates ID"

puts "updating inverse storage"
Card.search(right: :inverse).each &:save!
Card.search(right: :inverse_title).each do |c|
  c.update! content: c.standardize_content(c.item_names)
end
idcard = codename.card
puts "renaming id card"
idcard.update! name: identifier_name, skip: :update_referer_content

puts "creating new company"
company = Card.create! name: company_name, type: :company
puts "merging into #{company.name}"
idcard.merge_into company

Card.search type: :metric, left: codename do |metric|
  puts "updating name of metric: #{metric.name}"
  metric.update! name: [company_name, metric.name.right], skip: :update_referer_content
end

puts "changing id card type"
idcard.update! type: :company_identifier
