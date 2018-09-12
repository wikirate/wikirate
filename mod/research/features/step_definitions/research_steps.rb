And(/^I research$/) do |table|
  # table is a table.hashes.keys # => [:metric, :company, :year]
  hash = table.hashes.first
  fill_autocomplete("metric", with: hash[:metric])
  fill_autocomplete("wikirate_company", with: hash[:company])
  select_from_select2(hash[:year], from: "year")
end