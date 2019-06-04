
When(/^I edit answer of "([^"]*)" for "([^"]*)" for "([^"]*)"$/) do |m, c, y|
  visit "#{m}+#{c}+#{y}?view=edit"
end

Then(/^Unknown should not be checked$/) do
  expect(unknown_checkbox).not_to be_checked
end

Then(/^value select field should be empty$/) do
  expect(answer_value).to be_empty
end

Then(/^value input field should be empty$/) do
  expect(answer_value).to be_empty
end

Then(/^value input field should not be disabled$/) do
  expect(value_input_field).not_to be_disabled
end

Then(/^value select field should not be disabled$/) do
  expect(value_select_field).not_to be_disabled
end

def answer_value
  page.execute_script "$('.card-form').setContentFieldsFromMap()"
  page.evaluate_script %Q{$("[name='card[subcards][+value][content]']").val()}
end

def value_input_field
  find(".card-editor.RIGHT-value .content-editor input:not(.current_revision_id)")
end

def value_select_field
  find(".card-editor.RIGHT-value .content-editor select")
end

def unknown_checkbox
  find(".RIGHT-unknown input[type=checkbox]")
end
