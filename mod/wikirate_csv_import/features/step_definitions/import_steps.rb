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

Then(/^I check checkbox for import item (\d+)$/) do |row|
  check_import_item row
end

def check_import_item row
  within("table", visible: false) do
    within("tr[data-csv-row-index='#{row.to_i - 1}'", visible: false) do
      checkbox = find("input[type=checkbox]", visible: false)
      checkbox.set(true) # unless checkbox.checked?
    end
  end
end

And(/^I imported rows ([\d,\s]+)$/) do |arg|
  rows = arg.split(",").map { |n| n.strip.to_i }
  start_import rows
  finish_import
end

When(/^I start import for rows ([\d,\s]+)$/) do |arg|
  rows = arg.split(",").map { |n| n.strip.to_i }
  start_import rows
end

When(/^import is executed$/) do
  finish_import
end

def start_import rows
  check "all"
  uncheck "all"
  rows.each do |row|
    check_import_item row
  end
  button = find(:button, "Import", visible: false)
  button.click
  sleep 1
end

def finish_import
  Delayed::Worker.new.work_off
  sleep 3
  wait_for_ajax
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

Then(/^I fill in "(.*)" for import item (\d+)$/) do |text, row|
  table = find("table")
  within(table) do
    row = find("tr[data-csv-row-index='#{row}'")
    within(row) do
      find("input[type=text]").set(text)
    end
  end
end
