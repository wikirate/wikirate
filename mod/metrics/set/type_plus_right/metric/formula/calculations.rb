# don't update if it's part of scored metric update
event :update_metric_values, :prepare_to_store,
      on: :update, changed: :content do
  @existing = ::Set.new metric_card.all_answers.pluck(:id)

  calculate_all_values do |company, year, value|
    if (answer = metric_card.answer company, year)
      @existing.delete answer.id
      answer.update_value value
    else
      add_value company, year, value
    end
  end
  Answer.where(answer_id: @existing.to_a).delete_all
end

# don't update if it's part of scored metric create
event :create_metric_values, :finalize, #prepare_to_store,
      on: :create, changed: :content, when: proc { |c| c.content.present? }  do
  # reload set modules seems to be no longer necessary
  # it used to happen at this point that left has type metric but
  # set_names includes "Basic+formula+*type plus right"
  # reset_patterns
  # include_set_modules
  calculate_all_values do |company, year, value|
    add_value company, year, value
  end
end

def add_value company, year, value
  Answer.create_calculated_answer metric_card, company, year, value
end

def calculate_all_values
  calculator.result.each_pair do |year, companies|
    companies.each_pair do |company, value|
      yield company, year, value if value
    end
  end
end

# @param [Hash] opts
# @option opts [String] :company
# @option opts [String] :year optional
def calculate_values_for opts={}
  unless opts[:company]
    raise Card::Error, "#calculate_values_for: no company given"
  end
  no_value = true
  calculator.result(opts).each_pair do |year, companies|
    no_value = false
    value = companies[opts[:company]]
    yield year, value
  end
  yield opts[:year], nil if opts[:year] && no_value
end

private

def calculator_class
  @calculator_class ||=
    if wiki_rating?
      ::Formula::WikiRating
    elsif ::Formula::Translation.valid_formula? content
      ::Formula::Translation
    elsif ::Formula::Ruby.valid_formula? content
      ::Formula::Ruby
    else
      ::Formula::Wolfram
    end
end

def calculator
  @calculator ||= calculator_class.new self
end
