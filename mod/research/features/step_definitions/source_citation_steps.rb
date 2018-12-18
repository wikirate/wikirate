require_relative "../../../../test/shared_data/samples"
include SharedData::Samples

When(/^I research answer "([^"]*)" for year "([^"]*)"$/) do |answer, year|
  visit path_to("new answer")
  fill_autocomplete("metric", with: "Joe User+RM")
  fill_autocomplete("wikirate_company", with: "Apple Inc")
  select_year year
  fill_in "Answer", with: answer
end

And(/^I cite source for 2008 confirming$/) do |expected_msg|
  add_source :star_wars
  confirm_citation expected_msg.tr("\n", " ")
end

When(/^I visit cited source$/) do
  go_to_source :star_wars
end

When(/^I visit cited source without year$/) do
  go_to_source :darth_vader
end

And(/^I cite source "([^"]*)"$/) do |wikipedia_article|
  add_source :"#{wikipedia_article.downcase}"
  confirm_citation
end

And(/^I cite source$/) do
  add_source
  confirm_citation
end

And(/^I click cite and confirm$/) do
  confirm_citation
end

And(/^I cite source without year confirming$/) do |expected_msg|
  add_source
  confirm_citation expected_msg.tr("\n", " ")
end

And(/^I cite source without year dismissing$/) do |expected_msg|
  add_source
  msg = dismiss_confirm do
    click_link_or_button "Cite!"
  end
  expect(msg).to eq expected_msg.tr("\n", " ")
end

def confirm_citation expected_msg=nil
  msg = accept_confirm { click_link_or_button "Cite!" }
  return unless expected_msg
  expect(msg).to eq expected_msg
end

def add_source wikipedia_article=:darth_vader
  source = sample_source wikipedia_article
  fill_in "source_search_term", with: source.link_url
  click_button "Add URL Source"
end

def go_to_source wikipedia_article
  source = sample_source wikipedia_article
  visit path_to("card #{source.name}")
end

When(/^I dismiss citation$/) do
  page.driver.browser.switch_to.alert.dismiss
end
