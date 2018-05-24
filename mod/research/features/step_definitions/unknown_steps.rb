
When(/^I edit answer of "([^"]*)" for "([^"]*)" for "([^"]*)"$/) do |metric, company, year|
  visit "#{metric}+#{company}+#{year}?view=edit"
end

Then(/^Unknown should not be checked$/) do
  expect(unknown_checkbox).not_to be_checked
end

Then(/^value select field should be disabled and empty$/) do
  select = value_select_field
  expect(select).to be_disabled
  expect(select.value).to be_empty
end

Then(/^value input field should be disabled and empty$/) do
  input = value_input_field
  expect(input).to be_disabled
  expect(input.value).to be_empty
end

Then(/^value input field should not be disabled$/) do
  expect(value_input_field).not_to be_disabled
end

Then(/^value select field should not be disabled$/) do
  expect(value_select_field).not_to be_disabled
end

def value_input_field
  find(".card-editor.RIGHT-value .content-editor input:not(.current_revision_id)")
end

def value_select_field
  find(".card-editor.RIGHT-value .content-editor select")
end

def unknown_checkbox
  find("input#card_subcards__value_subcards__Unknown_content")
end
