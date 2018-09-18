And(/^I research$/) do |table|
  # table is a table.hashes.keys # => [:metric, :company, :year]
  hash = table.hashes.first

  visit path_to("/new answer")
  fill_autocomplete("metric", with: hash[:metric])
  fill_autocomplete("wikirate_company", with: hash[:company])
  select_year hash[:year]
end

When(/^I open the year list$/) do
  find("[name='year'] + .select2-container").click
end

When(/^I click the next button$/) do
  page.execute_script %{$('a:contains("chevron_right")').click()}
  #click_link_or_button("chevron_right")
end
