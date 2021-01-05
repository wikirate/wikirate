class Answer
  # class methods for the Answer (lookup) constant
  module AnswerClassMethods
    include Export::ClassMethods

    SEARCH_OPTS = {
      page: [:limit, :offset],
      sort: true,
      return: true,
      uniq: true
    }.freeze

    VALUE_JOINT = Card::Set::Abstract::Value::JOINT

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
    # @option opts [Hash] :sort
    # @option opts [Integer] :limit
    # @option opts [Integer] :offset
    # @return answer card objects
    def search opts={}
      args = extract_search_args opts
      search_where(opts).uniq_select(args[:uniq], args[:return])
                        .sort(args[:sort])
                        .paging(args[:page])
                        .return(args[:return])
    end

    def existing id
      return unless id
      for_card(id) || (refresh(id) && for_card(id))
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

    def unknown? val
      val.to_s.casecmp("unknown").zero?
    end

    def to_numeric val
      Answer.unknown?(val) || !val.number? ? nil : val.to_d
    end

    # convert value format to lookup-table-suitable value
    # @return nil or String
    def value_to_lookup value
      return nil unless value.present?
      value.is_a?(Array) ? value.join(VALUE_JOINT) : value.to_s
    end

    # convert value from lookup table to
    def value_from_lookup string, type
      type == :multi_category ? string.split(VALUE_JOINT) : string
    end

    private

    def extract_search_args args
      SEARCH_OPTS.each_with_object({}) do |(cat, keys), hash|
        hash[cat] = keys.is_a?(Array) ? args.extract!(*keys) : args.delete(cat)
      end
    end

    def search_where args
      cond = where_condition args[:where], args
      where(*cond)
    end

    def where_condition explicit, implicit
      Array.wrap(explicit.blank? ? implicit : explicit)
    end
  end
end
