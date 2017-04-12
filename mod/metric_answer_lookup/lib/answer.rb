class Answer < ActiveRecord::Base
  include LookupTable
  include Filter

  validates :answer_id, numericality: { only_integer: true }, presence: true
  validate :must_be_an_answer, :card_must_exist, :metric_must_exit

  def card_must_exist
    return if card
    errors.add :answer_id, "no card with id #{answer_id}"
  end

  def must_be_an_answer
    return if card.type_id == Card::MetricValueID
    errors.add :answer_id, "not a metric answer: #{Card.fetch_name answer_id}"
  end

  def metric_must_exit
    unless metric_card
      errors.add :metric_id, "#{fetch_metric_name} does not exist"
      return
    end
    return if metric_card.type_id == Card::MetricID
    errors.add :metric_id, "#{fetch_metric_name} is not a metric"
  end

  module ClassMethods
    def create card
      ma = Answer.new
      ma.answer_id = card.id
      ma.refresh
    end

    def create! card
      ma = Answer.new
      ma.answer_id = card.id
      raise ActiveRecord::RecordInvalid, ma if ma.invalid?
      ma.refresh
    end

    def create_or_update cardish, *fields
      ma_card_id = card_id(cardish)
      ma = Answer.find_by_answer_id(ma_card_id) || Answer.new
      ma.answer_id = ma_card_id
      # update all fields if record is new
      fields = nil if ma.new_record?
      ma.refresh *fields
    end

    def fetch where, sort_args={}, paging={}
      where = Array.wrap where
      mas = Answer.where(*where)
      mas = sort mas, sort_args
      mas = mas.limit(paging[:limit]).offset(paging[:offset]) if paging.present?
      mas.pluck(:answer_id).map do |id|
        Card.fetch id
      end
    end

    def sort mas, args
      return mas unless valid_sort_args? args
      mas = importance_sort mas, args if args[:sort_by].to_sym == :importance
      sort_by = args[:sort_by]
      sort_by = "CAST(#{sort_by} AS #{args[:cast]})" if args[:cast]
      mas.order "#{sort_by} #{args[:sort_order]}"
    end

    def importance_sort mas, args
      mas = mas.joins "LEFT JOIN cards AS c " \
                      "ON answers.metric_id = c.left_id " \
                      "AND c.right_id = #{Card::VoteCountID}"
      args[:sort_by] = "COALESCE(c.db_content, 0)"
      args[:cast] = "signed"
      mas
    end

    def valid_sort_args? args
      return unless args.present? && args[:sort_by]
      return true if args[:sort_by].to_sym == :importance
      Answer.column_names.include? args[:sort_by].to_s
    end

    def refresh ids=nil, *fields
      ids &&= Array(ids)
      if ids
        ids.each do |ma_id|
          begin
            create_or_update ma_id, *fields
          rescue => e
            puts "failed: #{ma_id}"
          end
        end
      else
        count = 0
        Card.where(type_id: Card::MetricValueID).pluck_in_batches(:id) do |batch|
          count += batch.size
          puts "#{batch.first} - #{count}"
          refresh(batch, *fields)
        end
      end
    end

    def card_id cardish
      case cardish
      when Integer then
        cardish
      when Card then
        cardish.id
      end
    end
  end

  extend ClassMethods

  def card_column
    :answer_id
  end

  def fetch_answer_id
    card.id
  end

  def fetch_company_id
    card.left.right_id
  end

  def fetch_metric_id
    metric_card.id
  end

  def fetch_record_id
    card.left_id
  end

  def fetch_metric_name
    card.cardname.left_name.left
  end

  def fetch_company_name
    card.cardname.left_name.right
  end

  def fetch_title_name
    card.cardname.parts.second
  end

  def fetch_record_name
    card.cardname.left
  end

  def fetch_year
    card.cardname.right.to_i
  end

  def fetch_imported
    return unless (action = card.value_card.actions.last)
    action.comment == "imported"
  end

  def fetch_designer_id
    metric_card.left_id
  end

  def fetch_creator_id
    card.creator_id
  end

  def fetch_designer_name
    card.cardname.parts.first
  end

  def fetch_policy_id
    return unless (policy_pointer = metric_card.fetch(trait: :research_policy))
    policy_name = policy_pointer.item_names.first
    (pc = Card.quick_fetch(policy_name)) && pc.id
  end

  def fetch_metric_type_id
    return unless (metric_type_pointer = metric_card.fetch(trait: :metric_type))
    metric_type_name = metric_type_pointer.item_names.first
    (mtc = Card.quick_fetch(metric_type_name)) && mtc.id
  end

  def fetch_value
    card.value
  end

  def fetch_numeric_value
    return unless metric_card.numeric?
    val = fetch_value
    return if unknown?(val) || !val.number?
    val.to_d
  end

  def fetch_updated_at
    return card.updated_at unless (vc = card.value_card)
    [card.updated_at, vc.updated_at].compact.max
  end

  def fetch_checkers
    return unless (cb = card.field(:checked_by)) && cb.checked?
    cb.checkers.join(", ")
  end

  def fetch_check_requester
    return unless (cb = card.field(:checked_by)) && cb.check_requested?
    cb.check_requester
  end

  def fetch_latest
    return true unless (latest_year = latest_year_in_db)
    @new_latest = (latest_year < fetch_year)
    latest_year <= fetch_year
  end

  def latest_year_in_db
    Answer.where(record_id: fetch_record_id).maximum(:year)
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

  def latest_to_false
    Answer.where(
      record_id: record_id, latest: true
    ).update_all(latest: false)
  end

  def latest= value
    latest_to_false if @new_latest
    super
  end

  def csv_line
    CSV.generate_line [metric_name, company_name, year, value]
  end

  private

  def unknown? val
    val.casecmp("unknown").zero?
  end

  def metric_card
    @metric_card ||= Card.quick_fetch(fetch_metric_name)
  end
end
