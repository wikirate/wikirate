module Capybara
  module Node
    module Actions
      def choose_value el, value
        id = el["id"]
        session.execute_script("$('##{id}').val('#{value}')")
        session.execute_script("$('##{id}').trigger('chosen:updated')")
        session.execute_script("$('##{id}').change()")

        # code below doesn't work on wikirate because if you select an item in
        # a very long list the list gets pushed below the navigation bar
        # find("label", text: field)
        #   .find(:xpath,"..//a[@class='chosen-single']")
        #   .click
        # li = find("li", text: value, visible: false)
        # li.click
        # # If the list element is too far down the list then the first click
        # # scrolls it up but doesn't select it. It needs another click.
        # # A selected item is no longer visible (because the list disappears)
        # if li.visible?
        #   li.click
        # end
      end
    end
  end
end

#
# When /^(?:|I )single-select "([^"]*)" from "([^"]*)"$/ do |value, field|
#   select =
#     find("label", text: field).find(:xpath, "..//select", visible: false)
# end

Capybara.default_max_wait_time = 20

When(/^I press "([^"]*)" within "([^"]*)"$/) do |button, scope_selector|
  within(scope_selector) do
    click_button(button)
  end
end

# When(/^I wait for ajax response$/) do
#  Timeout.timeout(Capybara.default_wait_time) do
#    sleep(0.5) while page.evaluate_script("jQuery.active") != 0
#  end
# end

When(/^I print html of the page$/) do
  puts page.html
end

And(/^I click on item "([^"]*)"$/) do |item|
  find("td", text: item).click
end

And(/^I click on "([^"]*)" and confirm$/) do |link|
  page.accept_confirm { click_link_or_button(link) }
end

When(/^I click on metric "([^"]*)"$/) do |metric|
  find(:css, ".add-formula").find("h4", text: metric).click
end

When(
  /^(?:|I )fill in "([^"]*)" with card path of source with link "([^"]*)"$/
) do |field, value|
  duplicates = Card::Set::Self::Source.find_duplicates value
  duplicated_card = duplicates.first.left if duplicates.any?

  url = "#{Card::Env[:protocol]}#{Card::Env[:host]}"\
        "/#{duplicated_card.name.url_key}"
  fill_in(field, with: url)
end

Then(/^Within "([^"]*)" I should not see "([^"]*)"$/) do |section, text|
  # page.should have_css(, :text => "[Name]")
  within(section) do
    expect(page).not_to have_content(text)
  end
end

Then(/^I expect element "([^"]*)" exists$/) do |selector|
  expect(page).to have_css(selector)
end

When(/^(?:|I )solocomplete "([^"]*)" within "([^"]*)"$/) do |value, scope|
  within(scope) do
    find(".chosen-single").click
    find(".chosen-search input").set value
    find(".chosen-results li").click
  end
end

When(/^I edit card "([^"]*)"$/) do |cardname|
  visit "/card/edit/#{cardname.to_name.url_key}"
end

fill_rg = /^(?:|I )fill in "([^"]*)" field with "([^"]*)" within "([^"]*)"$/
When fill_rg do |selector, value, scope_selector|
  within(scope_selector) do
    find(selector).set value
  end
end
fill_rg = /^(?:|I )fill in "([^"]*)" with "([^"]*)" within "([^"]*)"$/
When fill_rg do |selector, value, scope_selector|
  within(scope_selector) do
    fill_in(selector, with: value)
  end
end

When(/^I fill in company with "([^"]*)"$/) do |company|
  fill_in_pointer_field :company, company
end

# When(/^I fill in year with "([^"]*)"$/) do |year|
#   fill_in_pointer_field :year, year
# end

When(/^I fill in value with "([^"]*)"$/) do |value|
  fill_in_value value
end

When(/^I fill in source url with "([^"]*)"$/) do |url|
  fill_in "card_subcards__source_subcards_new_source_subcards__Link_content",
          with: url
end

regax = /
    ^I fill in metric value with "([^"]*)" as company,\s
    "([^"]*)" as year, and "([^"]*)" as value$
  /x
When(regax) do |company, year, value|
  fill_in_pointer_field :company, company
  fill_in_pointer_field :year, year
  fill_in_value value
end

def fill_in_pointer_field name, value
  within "fieldset.editor .RIGHT-#{name}" do
    fill_in "pointer_item", with: value
  end
end

def fill_in_value value
  fill_in "card_subcards__value_content", with: value
end

When(/^(?:|I )select "([^"]*)" from hidden "([^"]*)"$/) do |value, field|
  # our select list is not a real select list. it is a hidden input
  find(:xpath, "//input[@id='#{field}']", visible: false).set value
end

When /^(?:|I )single-select "([^"]*)" as value$/ do |value|
  find("#card_subcards__values_content_chosen a.chosen-single").click
  find("li", text: value).click
end

Then(/^I should see a row with "(.+)"$/) do |value|
  values = value.split("|")
  html = page.body
  expect(html).to have_tag("table") do
    with_tag("tr") do
      values.each do |v|
        with_tag("td", text: v)
      end
    end
  end
end

Then(/^I uncheck all checkboxes$/) do
  all("input[type=checkbox]", visible: false).each do |checkbox|
    checkbox.click if checkbox.checked?
  end
end

Then(/^I check checkbox in row (\d+)$/) do |row|
  table = find("table")
  within(table) do
    row = all("tr")[row.to_i]
    within(row) do
      checkbox = find("input[type=checkbox]")
      checkbox.click unless checkbox.checked?
    end
  end
end

Then(/^I check checkbox for csv row (\d+)$/) do |row|
  table = find("table", visible: false)
  within(table) do
    row = find("tr[data-csv-row-index='#{row.to_i - 1}'", visible: false)
    within(row) do
      checkbox = find("input[type=checkbox]", visible: false)
      checkbox.click unless checkbox.checked?
    end
  end
end

Then(/^I fill in "(.*)" in row (\d+)$/) do |text, row|
  table = find("table")
  within(table) do
    row = all("tr")[row.to_i]
    within(row) do
      find("input[type=text]").set(text)
    end
  end
end

Then(/^I fill in "(.*)" for csv row (\d+)$/) do |text, row|
  table = find("table")
  within(table) do
    row = find("tr[data-csv-row-index='#{row}'")
    within(row) do
      find("input[type=text]").set(text)
    end
  end
end

Then /^(?:|I )should see "([^"]*)" or "([^"]*)"$/ do |text1, text2|
  begin
    expect(page).to have_content(text1)
  rescue
    expect(page).to have_content(text2)
  end
end

Then(/^I should see a "(.*)" icon$/) do |icon|
  expect(page.body).to have_tag "i.fa-#{ICONS[icon]}"
end

Then(/^I should see a "(.*)" icon with tooltip "(.*)"$/) do |icon, title|
  expect(page.body)
    .to have_tag("i", with: { class: "fa-#{ICONS[icon]}", title: title })
end

Then(/^I should not see a "(.*)" icon$/) do |icon|
  expect(page.body).to_not have_tag "i.fa-#{ICONS[icon]}"
end

When(/^I click the drop down button$/) do
  find(".fa-caret-right").click
end

When(/^I click the drop down button for "(.*)"$/) do |text|
  find("td", text: text).find(:xpath, "..")
                        .find(".fa-caret-right").click
end

def select_from_chosen item_text, selector, within
  within(within) do
    id = find_field(selector, visible: false)[:id]
    option_value = page.execute_script(%(
      val1 = $(\"##{id} option:contains('#{item_text}')\").val();
      value = [val1];
      if ($('##{id}').val()) {$.merge(value, $('##{id}').val())}
      return value
    ))
    update_chosen_select_value id, option_value
  end
end

def update_chosen_select_value id, value
  page.execute_script("$('##{id}').val(#{value})")
  page.execute_script("$('##{id}').trigger('chosen:updated')")
end

When(/^I select "(.*)" from choosen within "(.*)"$/) do |item_text, within|
  select_from_chosen(item_text, "pointer_multiselect", within)
end

When(/^I press link button "(.*)"$/) do |name|
  find("a", text: name, visible: false).click
end

When(/^(?:|I )click! on "([^"]*)"$/) do |link|
  click_link_or_button(link, visible: false)
end

When(/^I maximize the browser$/) do
  page.driver.browser.manage.window.maximize
end

ICONS = {
  "check request" => "check-circle-o",
  "comment" => "commenting",
  "remove" => "times-circle-o"
}.freeze

When(/^I click on the "(.*)" icon$/) do |icon|
  find(:css, "i.fa.fa-#{ICONS[icon]}").click
end

And(/^I hover over "([^"]*)"$/) do |text|
  find(:link_or_button, text: text).hover
end

And(/^I accept alert$/) do
  page.driver.browser.switch_to.alert.accept
end
