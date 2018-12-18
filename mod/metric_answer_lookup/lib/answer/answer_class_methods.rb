class Answer
  module AnswerClassMethods
    SEARCH_OPTS = { sort: [:sort_by, :sort_order, :cast],
                    page: [:limit, :offset],
                    return: [:return],
                    uniq: [:uniq],
                    where: [:where] }.freeze

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

    def latest_answer_card metric_id, company_id
      a_id = where(metric_id: metric_id, company_id: company_id,
                   latest: true).pluck(:answer_id).first
      a_id && Card.fetch(a_id)
    end

    def latest_year metric_id, company_id
      where(metric_id: metric_id, company_id: company_id, latest: true).pluck(:year).first
    end

    def answered? metric_id, company_id
      where(metric_id: metric_id, company_id: company_id).exist?
    end

    def find_by_answer_id answer_id
      find_by_card_id answer_id
    end

    private

    def split_search_args args
      hash = {}
      SEARCH_OPTS.each { |cat, keys| hash[cat] = args.extract!(*keys) }
      hash[:uniq].merge! hash[:return] if hash[:uniq] && hash[:return]
      hash[:where] = args unless hash[:where].present?
      hash[:where] = Array.wrap(hash[:where])
      hash
    end
  end
end
