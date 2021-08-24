card_accessor :formula, type: PhraseID
card_accessor :metric_variables

Card::Content::Chunk::FormulaInput # trigger load.  might be better place?

delegate :parser, :calculator_class, to: :formula_card

def calculator parser_method=nil
  p = parser
  p.send parser_method if parser_method
  calculator_class.new p, normalizer: Answer.method(:value_to_lookup),
                          years: year_card.item_names,
                          companies: company_group_card.company_ids
end

# update all answers of this metric and the answers of all dependent metrics
def deep_answer_update
  calculate_answers
  each_depender_metric(&:calculate_answers)
end

# param @args [Hash] :company_id, :year, both, or neither.
def calculate_answers args={}
  c = Calculate.new self, args
  c.prepare
  c.transact
  c.clean
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
    old_company_ids
    expirables
    overridden_hash
  end

  def transact
    wipe_old_calculations
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

  def old_company_ids
    @old_company_ids ||= unique_company_ids
  end

  def unique_company_ids
    array = if @company_id
              [@company_id]
            else
              answers.select(:company_id).distinct.pluck :company_id
            end
    ::Set.new array
  end

  def wipe_old_calculations
    answers.where(answer_id: nil).delete_all if old_company_ids.present?
    if overridden_hash.present?
      answers.where("answer_id is not null").update_all(overridden_value: nil)
    end
  end

  def expirables
    return [] unless old_company_ids.present?
    @expirables ||= answers.joins("JOIN cards AS companies ON company_id = companies.id")
                           .pluck :name, :year
  end

  def overridden_hash
    return {} unless old_company_ids.present?
    @overridden_hash ||= answers.where("answer_id is not null")
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
    Answer.insert_all answer_hashes if answer_hashes.present?
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

  def update_cached_counts
    (metric_cache_count_cards +
      topic_cache_count_cards +
      company_cache_count_cards).each(&:update_cached_count)
  end

  def company_cache_count_cards
    (old_company_ids | unique_company_ids).map do |company_id|
      %i[metric metric_answer wikirate_topic].map { |fld| Card.fetch [company_id, fld] }
    end.flatten
  end

  def metric_cache_count_cards
    %i[metric_answer wikirate_company].map { |fld| Card.fetch [metric.name, fld] }
  end

  def topic_cache_count_cards
    TypePlusRight::WikirateTopic::WikirateCompany
      .company_cache_cards_for_topics metric.wikirate_topic_card&.item_names
  end

  def restore_overridden_value
    calculated_answer metric_card, company, year, overridden_value
  end
end

# The bulk_insert gem stopped working with the rail 6.1 upgrade;
# This is a bit of a hack to get it working again.
module ConnectionPatch
  def type_cast_from_column _column, value
    value
  end
end

ActiveRecord::ConnectionAdapters::Mysql2Adapter.include ConnectionPatch
