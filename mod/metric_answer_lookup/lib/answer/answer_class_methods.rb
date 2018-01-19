class Answer
  module AnswerClassMethods
    SEARCH_OPTS = { sort: [:sort_by, :sort_order, :cast],
                    page: [:limit, :offset],
                    return: [:return],
                    uniq: [:uniq],
                    where: [:where] }.freeze

    def create cardish
      ma = Answer.new
      ma.answer_id = card_id cardish
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
      ma.refresh(*fields)
    end

    # @return answer card objects
    def fetch where_args, sort_args={}, page_args={}
      where_opts = Array.wrap(where_args)
      where(*where_opts).sort(sort_args).paging(page_args).answer_cards
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
                          .sort(args[:sort])
                          .paging(args[:page])
                          .return(args[:return])
    end

    def split_search_args args
      hash = {}
      SEARCH_OPTS.each do |cat, keys|
        hash[cat] = args.extract!(*keys)
      end
      hash[:uniq].merge! hash[:return] if hash[:uniq] && hash[:return]
      hash[:where] = args unless hash[:where].present?
      hash[:where] = Array.wrap(hash[:where])
      hash
    end

    # @param ids [Integer, Array<Integer>] card ids of metric answer cards
    def refresh ids=nil, *fields
      ids = Array(ids).compact
      if ids.present?
        ids.each { |ma_id| refresh_entry fields, ma_id }
      else
        refresh_all fields
      end
    end

    def refresh_entry fields, card_id
      if Card.exists? card_id
        create_or_update card_id, *fields
      else
        delete_answer_for_card_id card_id
      end
    rescue StandardError => e
      raise e, "failed to refresh answer lookup table " \
               "for card id #{card_id}: #{e.message}"
    end

    def delete_answer_for_card_id card_id
      find_by_answer_id(card_id)&.destroy
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
      when Integer then cardish
      when Card    then cardish.id
      end
    end

    def latest_answer_card metric_id, company_id
      a_id = where(metric_id: metric_id, company_id: company_id,
                   latest: true).pluck(:answer_id).first
      a_id && Card.fetch(a_id)
    end

    def latest_year metric_id, company_id
      where(metric_id: metric_id,
            company_id: company_id,
            latest: true).pluck(:year).first
    end

    def answered? metric_id, company_id
      where(metric_id: metric_id, company_id: company_id).exist?
    end

    def unknown? val
      val.to_s.casecmp("unknown").zero?
    end

    def find_by_answer_id answer_id
      answer_id ? super : nil
    end
  end
end
