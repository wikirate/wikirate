

When(/^I research answer "([^"]*)" for year "([^"]*)"$/) do |answer, year|
  visit path_to("new metric_value")
  fill_autocomplete("metric", with: "Joe User+researched")
  fill_autocomplete("wikirate_company", with: "Apple Inc")
  select_year year
  fill_in "Answer", with: answer
end

And(/^I cite source for 2008$/) do
  cite_source "Star_Wars"
end

When(/^I go to cited source$/) do
  go_to_source "Star_Wars"
end

And(/^I cite source without year$/) do
  cite_source "Death_Star"
end

def cite_source wikipedia_article
  source = sample_source wikipedia_article
  fill_in "URL", with: source.url
  click_button "Add"
  click_link_or_button "Cite!"
end

def go_to_source wikipedia_article
  source = sample_source wikipedia_article
  visit path_to(source.name)
end

When(/^I confirm citation/) do
  page.driver.browser.switch_to.alert.accept
end

When /^I dismiss citation$/ do
  page.driver.browser.switch_to.alert.dismiss
end
