def calculation_in_progress!
  Answer.where(id: all_dependent_answer_ids).update_all(calculating: true)
end


# update all answers of this metric and the answers of all dependent metrics
def deep_answer_update initial_update=false
  @initial_update = initial_update
  recalculate_answers
  each_dependent_formula_metric(&:recalculate_answers)
end

def recalculate_answers
  remove_unchanged_answers do
    calculate_all_values(&method(:update_or_add_answer))
  end
end

def remove_unchanged_answers
  @existing = ::Set.new answer_ids
  yield if block_given?
  Answer.where(id: @existing.to_a).delete_all
ensure
  @existing = nil
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

def update_or_add_answer company, year, value
  if (aw = answer(company, year))
    update_answer aw, company, year, value
  else
    add_answer company, year, value
  end
rescue => e
  errors.add :answer, "Error storing calculated value: #{e.message}"
  raise e
end

def update_answer answer, company, year, value
  @existing.delete answer.id if @existing
  if @initial_update
    answer.calculated_answer self, company, year, value
  elsif already_researched? answer
    update_overridden_calculated_value answer, value
  else
    answer.update_value value
  end
end

def add_answer company, year, value
  Answer.create_calculated_answer metric_card, company, year, value
end

delegate :calculator, to: :formula_card

def to_company_id company
  raise Card::Error, "#calculate_values_for: no company given" unless company
  return company if company.is_a?(Integer)
  Card.fetch_id(company)
end
