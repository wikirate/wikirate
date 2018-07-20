# don't update if it's part of scored metric update
event :update_metric_answers, :prepare_to_store, on: :update, changed: :content do
  replacing_existing_answers do
    calculate_all_values do |company, year, value|
      update_or_add_answer company, year, value
    end
  end
end

# don't update if it's part of scored metric create
event :create_metric_answers, :finalize, # prepare_to_store,
      on: :create, changed: :content, when: :content?  do
  # reload set modules seems to be no longer necessary
  # it used to happen at this point that left has type metric but
  # set_names includes "Basic+formula+*type plus right"
  # reset_patterns
  # include_set_modules
  calculate_all_values do |company, year, value|
    add_value company, year, value
  end
end

def update_or_add_answer company, year, value
  if (answer = metric_card.answer company, year)
    @existing.delete answer.id
    answer.update_value value
  else
    add_value company, year, value
  end
rescue => e
  errors.add :answer, "Error storing calculated value: #{e.message}"
  raise e
end

def regenerate_answers
  replacing_existing_answers do
    create_metric_answers
  end
end

def replacing_existing_answers
  @existing = ::Set.new metric_card.all_answers.pluck(:id)
  yield
  Answer.where(id: @existing.to_a).delete_all
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
  values = calculator.result(opts)
  if values.present?
    company_id = to_company_id opts[:company]
    values.each_pair do |year, companies|
      value = companies[company_id]
      yield year, value
    end
  elsif opts[:year]
    yield opts[:year], nil
  end
end

private

def to_company_id company
  raise Card::Error, "#calculate_values_for: no company given" unless company
  return company if company.is_a?(Integer)
  Card.fetch_id(company)
end

def calculator_class
  @calculator_class ||=
    metric_card.calculator_class || ::Formula.calculator_class(clean_formula)
end

def calculator
  @calculator ||= calculator_class.new self
end
