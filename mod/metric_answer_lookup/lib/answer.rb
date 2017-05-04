# lookup table for metric answers
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
    SEARCH_OPTS = { sort: [:sort_by, :sort_order, :cast] ,
                    page: [:limit, :offset],
                    return: [:return],
                    uniq: [:uniq],
                    where: [:where]
                   }.freeze

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

    # @return answer card objects
    def fetch where_args, sort_args={}, page_args={}
      where_opts = Array.wrap(where_args)
      where(*where_opts).sort(sort_args).page(page_args).answer_cards
    end

    # @param opts [Hash] search options
    # If the :where option is used then its value is passed as argument list to AR's where
    # method. Otherwise all remaining values that are not sort or page options are
    # passed as hash to `where`.
    # @option opts [Array] :where
    # @option opts [Symbol] :sort_by column name or :importance
    # @option opts [Symbol] :sort_order :asc or :desc
    # @option opts [Integer] :limit
    # @option opts [Integer] :offset
    # @return answer card objects
    def search opts={}
      args = split_search_args opts
      where(*args[:where]).uniq_select(args[:uniq])
        .sort(args[:sort]).page(args[:page]).return(args[:return])
    end

    def split_search_args args
      hash = {}
      SEARCH_OPTS.each do |cat, keys|
        hash[cat] = args.extract!(*keys)
      end
      hash[:uniq].merge! hash[:return] if hash[:uniq] && hash[:return]
      hash[:where] ||= args
      hash[:where] = Array.wrap(hash[:where])
      hash
    end

    def refresh ids=nil, *fields
      if ids
        Array(ids).each do |ma_id|
          refresh_entry fields, ma_id
        end
      else
        refresh_all fields
      end
    end

    def refresh_entry fields, ma_id
      create_or_update ma_id, *fields
    rescue => e
      puts "failed to refresh metric answer: #{ma_id}"
      puts e.message
    end

    def refresh_all fields
      count = 0
      Card.where(type_id: Card::MetricValueID).pluck_in_batches(:id) do |batch|
        count += batch.size
        puts "#{batch.first} - #{count}"
        refresh(batch, *fields)
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

    def latest_answer_card metric_id, company_id
      a_id = where(metric_id: metric_id, company_id: company_id,
                   latest: true).pluck(:answer_id)
      a_id && Card.fetch(a_id)
    end

    def latest_year metric_id, company_id
      where(metric_id: metric_id,
            company_id: company_id,
            latest: true).pluck(:year)
    end

    def answered? metric_id, company_id
      where(metric_id: metric_id, company_id: company_id).exist?
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

require_relative "answer/active_record/relation"
