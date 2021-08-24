delegate :parser, :calculator_class, to: :formula_card

def calculator parser_method=nil
  p = parser
  p.send parser_method if parser_method
  calculator_class.new p, normalizer: method(:normalize_value),
                          years: year_card.item_names,
                          companies: company_group_card.company_ids
end

# update all answers of this metric and the answers of all dependent metrics
def deep_answer_update
  recalculate_answers
  each_depender_metric(&:recalculate_answers)
end

def recalculate_answers
  delete_non_overridden_answers
  process_calculations do |overridden, not_overridden|
    insert_calculations not_overridden
    update_overridden_calculations overridden
  end
  # expire_answers
  # update cached counts
  # update latest
end

def delete_non_overridden_answers
  answers.where(overridden_value: nil).delete_all
end

def overridden_hash
  answers.where("overridden_value is not null")
         .pluck(:company_id, :year)
         .each_with_object({}) do |(c, y), h|
    h["#{c}-#{y}"] = true
  end
end

def insert_calculations not_overridden
  answer_hashes = not_overridden.map do |calculation|
    calculation.answer_attributes.merge metric_id: id
  end
  Answer.insert_all answer_hashes
end

def update_overridden_calculations overridden

end

def process_calculations
  test = overridden_hash
  overridden = []
  not_overridden = []
  calculator.result.each do |calculation|
    if test["#{calculation.company_id}-#{calculation.year}"]
      overridden << calculation
    else
      not_overridden << calculation
    end
  end
  yield overridden, not_overridden
end





# def remove_unchanged_answers
#   @existing = ::Set.new answer_ids
#   yield if block_given?
#   Answer.where(id: @existing.to_a, answer_id: nil).delete_all
# ensure
#   @existing = nil
# end

# def calculate_all_values
#   calculator.result.each_pair do |year, company_hash|
#     company_hash.each_pair do |company, calculation|
#       value = calculation.value
#       yield company, year, value if value
#     end
#   end
# end

# @param company [cardish]
# @option years [String, Integer, Array] years to update value for (all years if nil)
def calculate_values_for company, years=nil
  calculations = calculator.result companies: company, years: years
  if calculations.present?
    calculations.each { |c| yield c.year, c.value }
  elsif years # yield with nil value to trigger deletion
    Array.wrap(years).each { |year| yield year, nil }
  end
end

def expire_answer company, year
  answer_name = Card::Name[metric_card.name, company, year.to_s]
  Director.expirees << answer_name
  Director.expirees << Card::Name[answer_name, :value]
end

# def update_answer answer, company, year, value
#   @existing&.delete answer.id
#   if @initial_update
#     answer.calculated_answer self, company, year, value
#   elsif already_researched? answer
#     update_overridden_calculated_value answer, value
#   else
#     answer.update_value value
#   end
# end

# def add_answer company, year, value
#   Answer.create_calculated_answer self, company, year, value
# end

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
