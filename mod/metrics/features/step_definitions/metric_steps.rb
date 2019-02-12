When(/^the submit button (should|should not) be disabled$/) do |should|
  if should.match?(/not/)
    expect(submit_button).not_to be_disabled
  else
    expect(submit_button).to be_disabled
  end
end

When(/^the weight total should be "(\d+)"$/) do |total|
  expect(weight_total).to eq(total)
end

When(/I set weight for "([^"]*)" to "(\d+)"$/) do |metric, weight|
  assign_weight metric, weight
end

# assign metric weight via jQuery
# (would be more idiomatic to use xpath)
def assign_weight metric, weight
  selector = "$('[data-card-name=\"#{metric}\"]')" \
             ".closest('tr').find('[name=\"pair_value\"]')"
  page.execute_script "#{selector}.val(#{weight});"
  page.execute_script "#{selector}.trigger('input');"
end

def weight_total
  find("#weight_sum").value.to_i
end

def submit_button
  find(".submit-button")
end


When(/^I edit answer$/) do
  find(:css, ".titled-view.TYPE-answer i.fa-pencil-square-o", visible: false).click
end
