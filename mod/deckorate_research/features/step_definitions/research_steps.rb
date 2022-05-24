When(/^I open the year list$/) do
  find("[name='year'] + .select2-container").click
end

When(/^I click the next button$/) do
  page.execute_script %{$('a:contains("chevron_right")').click()}
  # click_link_or_button("chevron_right")
end
