# lookup table for metric answers

class Answer < ActiveRecord::Base
  include LookupTable
  extend AnswerClassMethods

  include Filter
  include Validations
  include EntryFetch

  validates :answer_id, numericality: { only_integer: true }, presence: true
  validate :must_be_an_answer, :card_must_exist, :metric_must_exit

  def card_column
    :answer_id
  end

  def delete
    super.tap do
      if (latest_year = latest_year_in_db)
        Answer.where(
          record_id: record_id, year: latest_year
        ).update_all(latest: true)
      end
    end
  end

  def latest_year_in_db
    Answer.where(record_id: fetch_record_id).maximum(:year)
  end

  def latest_to_false
    Answer.where(record_id: record_id, latest: true)
          .update_all(latest: false)
  end

  def latest= value
    latest_to_false if @new_latest
    super
  end

  def self.csv_title
    CSV.generate_line ["ANSWER ID", "METRIC NAME", "COMPANY NAME", "YEAR",
                       "VALUE"]
  end

  def csv_line
    CSV.generate_line [answer_id, metric_name, company_name, year, value]
  end

  private

  def unknown? val
    val.casecmp("unknown").zero?
  end

  def metric_card
    @metric_card ||= Card.quick_fetch(fetch_metric_name)
  end

  def method_missing method_name, *args, &block
    card.send method_name, *args, &block
  end
end

require_relative "answer/active_record_extension"
Answer::ActiveRecord_Relation.send :include, Answer::ActiveRecordExtension
