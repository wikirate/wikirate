

Capybara.default_wait_time = 15

When /^I press "([^\"]*)" within "([^\"]*)"$/ do |button,scope_selector|
  within(scope_selector) do
    click_button(button)
  end
end

When /^I wait until ajax response$/ do
  Timeout.timeout(Capybara.default_wait_time) do
    while page.evaluate_script('jQuery.active') != 0 do
      sleep(0.5)
    end
  end
end

When /^I print html of the page$/ do
  puts page.html
end

When /^(?:|I )fill in "([^"]*)" with card path of source with link "([^"]*)"$/ do |field, value|
  duplicates = Card::Set::Self::Source.find_duplicates value
  duplicated_card = duplicates.first.left if duplicates.any?

  url = "#{ Card::Env[:protocol] }#{ Card::Env[:host] }/#{duplicated_card.cardname.url_key}"
  fill_in(field, :with => url)
end

Then /^Within "([^\"]*)" I should not see "([^\"]*)"$/ do |section, text|
  # page.should have_css(, :text => "[Name]")
  within(section) do
    expect(page).not_to have_content(text)
  end
end

Then /^I expect element "([^\"]*)" exists$/ do |selector|
  expect(page).to have_css(selector)
end

When /^(?:|I )solocomplete "([^"]*)" within "([^"]*)"$/ do |value, scope_selector|
  within(scope_selector) do
    find(".chosen-single").click
    find(".chosen-search input").set value
    find(".chosen-results li").click
  end
end