delegate :parser, :calculator_class, to: :formula_card

def calculator parser_method=nil
  p = parser
  p.send parser_method if parser_method
  calculator_class.new p, normalizer: method(:normalize_value),
                          years: year_card.item_names,
                          companies: company_group_card.company_ids
end

def calculation_in_progress!
  rel = all_depender_relation
  rel.where(overridden_value: nil).update_all calculating: true
  if rel.count > 1000
    # not worth it to loop through > 1000 answers
    # maybe we should clear cache?  maybe in integrate stage?
    # Card::Cache.reset_all
  else
    rel.each(&:expire)
  end
end

# update all answers of this metric and the answers of all dependent metrics
def deep_answer_update initial_update=false
  @initial_update = initial_update
  recalculate_answers
  each_depender_metric(&:recalculate_answers)
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
  calculator.result.each_pair do |year, company_hash|
    company_hash.each_pair do |company, calculation|
      value = calculation.value
      yield company, year, value if value
    end
  end
end

# @param company [cardish]
# @option years [String, Integer, Array] years to update value for (all years if nil)
def calculate_values_for company, years=nil, &block
  calculations = calculator.result companies: company, years: years
  if calculations.present?
    update_calculated_values calculations, company, &block
  elsif years # yield with nil value to trigger deletion
    Array.wrap(years).each { |year| yield year, nil }
  end
end

def update_calculated_values calculations, company
  company_id = to_company_id company
  calculations.each_pair do |year, companies|
    yield year, companies[company_id]&.value
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

private


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
