card_accessor :formula, type: PhraseID
card_accessor :metric_variables

Card::Content::Chunk::FormulaInput # trigger load.  might be better place?

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
  calculate_answers
  each_depender_metric(&:calculate_answers)
end

def calculate_answers args={}
  c = Calculate.new self, args
  c.prepare
  c.transact
  c.clean
end

# @param company [cardish]
# @option years [String, Integer, Array] years to update value for (all years if nil)
def update_value_for! company, years=nil
  calculate_answers company_id: company.card_id, year: years
end

class Calculate
  attr_reader :answers, :metric

  def initialize metric, args={}
    @metric = metric
    @company_id = args[:company_id]
    @year = args[:year]
    @answers = metric.answers args
  end

  def prepare
    # stash the following
    expirables
    overridden_hash
  end

  def transact
    delete_non_overridden_answers
    process_calculations do |overridden, not_overridden|
      insert_calculations not_overridden
      update_overridden_calculations overridden
    end
    update_latest
  end

  def clean
    expire_old_answers
  end

  private

  def delete_non_overridden_answers
    answers.where(overridden_value: nil).delete_all
  end

  def expirables
    @expirables ||= answers.joins("JOIN cards AS companies ON company_id = companies.id")
                           .pluck :name, :year
  end

  def overridden_hash
    @overridden_hash ||= answers.where("overridden_value is not null")
                                .pluck(:company_id, :year)
                                .each_with_object({}) do |(c, y), h|
      h["#{c}-#{y}"] = true
    end
  end

  def update_latest
    latest_rel.pluck(:id).each_slice(1000) do |ids|
      Answer.where("id in (#{ids.join ', '})").update_all latest: true
    end
  end

  def latest_rel
    answers.where <<-SQL
      NOT EXISTS (
        SELECT * FROM answers a1 
        WHERE a1.metric_id = answers.metric_id
        AND a1.company_id = answers.company_id
        AND a1.year > answers.year
      )
    SQL
  end

  def process_calculations
    overridden = []
    not_overridden = []
    metric.calculator.result(companies: @company_id, years: @year).each do |calculation|
      if overridden_hash["#{calculation.company_id}-#{calculation.year}"]
        overridden << calculation
      else
        not_overridden << calculation
      end
    end
    yield overridden, not_overridden
  end

  def insert_calculations not_overridden
    answer_hashes = not_overridden.map do |calculation|
      calculation.answer_attributes.merge metric_id: metric.id
    end
    Answer.insert_all answer_hashes
  end

  def update_overridden_calculations overridden
    overridden.each do |o|
      answers.where(company_id: o.company_id, year: o.year)
             .update_all overridden_value: o.value
    end
  end

  def expire_old_answers
    expirables.each { |company_name, year| expire_answer company_name, year }
  end

  def expire_answer company_name, year
    answer_name = Card::Name[metric.name, company_name, year.to_s]
    Director.expirees << answer_name
    Director.expirees << Card::Name[answer_name, :value]
  end
end

private

def normalize_value value
  ::Answer.value_to_lookup value
end

# The bulk_insert gem stopped working with the rail 6.1 upgrade;
# This is a bit of a hack to get it working again.
module ConnectionPatch
  def type_cast_from_column _column, value
    value
  end
end

ActiveRecord::ConnectionAdapters::Mysql2Adapter.include ConnectionPatch
