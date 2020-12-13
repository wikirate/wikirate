def calculation_in_progress!
  ids = all_dependent_answer_ids
  Answer.where(id: ids, overridden_value: nil).update_all(calculating: true)
  Answer.where(id: ids).each(&:expire)
end

def initial_calculation_in_progress!
  Answer.bulk_insert values: dummy_answers_attribs
end

# update all answers of this metric and the answers of all dependent metrics
def deep_answer_update initial_update=false
  @initial_update = initial_update
  recalculate_answers
  each_dependent_metric(&:recalculate_answers)
end

def recalculate_answers
  remove_unchanged_answers do
    calculate_all_values(&method(:update_or_add_answer))
  end
end

def remove_unchanged_answers
  @existing = ::Set.new answer_ids
  yield if block_given?
  Answer.where(id: @existing.to_a, answer_id: nil).delete_all
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
  values = calculator.result(opts)  # values by year and company
  if values.present?
    company_id = to_company_id opts[:company]
    values.each_pair do |year, companies|
      value = companies[company_id]
      yield year, value
    end
  elsif opts[:year] # yield with nil value to trigger deletion
    yield opts[:year], nil
  end
end

def update_or_add_answer company, year, value
  expire_answer company, year
  if (aw = answer_for(company, year))
    update_answer aw, company, year, value
  else
    add_answer company, year, value
  end
end

def expire_answer company, year
  answer_name = Card::Name[metric_card.name, company, year.to_s]
  Director.expirees << answer_name
  Director.expirees << Card::Name[answer_name, :value]
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
  shared_attribs = shared_dummy_answer_attribs
  calculator.answers_to_be_calculated.map do |company_id, year|
    shared_attribs.merge company_id: company_id, year: year
  end
end

# FIXME: setting latest to true here is wrong
def shared_dummy_answer_attribs
  {
    metric_id: id,
    designer_id: left_id,
    title_id: metric_designer_id,
    metric_type_id: metric_type_id,
    calculating: true,
    creator_id: Card::Auth.current_id,
    latest: true
  }
end

def to_company_id company
  raise Card::Error, "#calculate_values_for: no company given" unless company
  return company if company.is_a?(Integer)

  Card.fetch_id(company)
end

# The bulk_insert gem stopped working with the rail 6.1 upgrade;
# This is a bit of a hack to get it working again.
module ConnectionPatch
  def type_cast_from_column _column, value
    value
  end
end

ActiveRecord::ConnectionAdapters::Mysql2Adapter.include ConnectionPatch