event :update_lookup_answers, :integrate,
      on: :update, changed: :name do
  # FIXME: when renaming, the metric type gets confused at some point, and
  # calculated? does not correctly return true for calculated metrics
  # (which have MetricType::Researched among their singleton class's ancestors)
  # if this were working properly it could be in the when: arg.
  #
  expire
  rename_answers if refresh(true).calculated?
end

def calculation_in_progress!
  Answer.where(id: all_dependent_answer_ids).update_all(calculating: true)
end

def initial_calculation_in_progress!
  Answer.bulk_insert values: dummy_answers_attribs
end

# update all answers of this metric and the answers of all dependent metrics
def deep_answer_update initial_update=false
  @initial_update = initial_update
  recalculate_answers
  each_dependent_formula_metric(&:recalculate_answers)
end

def rename_answers
  Answer.where(metric_id: id).update_all metric_name: name,
                                          designer_name: name.parts.first,
                                          title_name: name.parts.second

  all_answers.each do |answer|
    answer.refresh :record_name
  end
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
rescue StandardError => e
  errors.add :answer, "Error storing calculated value: #{e.message}"
  raise e
end

def update_answer answer, company, year, value
  @existing&.delete answer.id
  if @initial_update
    answer.calculated_answer self, company, year, value
  elsif already_researched? answer
    update_overridden_calculated_value answer, value
  else
    answer.update_value value
  end
end

def add_answer company, year, value
  Answer.create_calculated_answer self, company, year, value
end

delegate :calculator, to: :formula_card

private

def dummy_answers_attribs
  calculator.answers_to_be_calculated.map do |company_id, year|
    unless Card[self, company_id]
      Card.create! name: [self, company_id], type_id: Card::RecordID
    end
    { metric_id: id, company_id: company_id, year: year, calculating: true,
      metric_name: name, latest: true }
  end
end

def to_company_id company
  raise Card::Error, "#calculate_values_for: no company given" unless company
  return company if company.is_a?(Integer)

  Card.fetch_id(company)
end
