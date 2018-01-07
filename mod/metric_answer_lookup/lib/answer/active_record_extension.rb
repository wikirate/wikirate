class Answer
  module ActiveRecordExtension
    NAME_COLUMNS = [:metric, :company, :designer, :title, :record].freeze

    def answer_cards
      map { |a| a.card }.compact
    end

    def value_cards
      left_ids = pluck :answer_id
      return [] unless left_ids.present?
      Card.search left_id: ["in"] + left_ids, right_id: Card::ValueID
    end

    def cards type
      col = "#{type}_id"
      unless Answer.column_names.include? col
        raise ArgumentError, "column doesn't exist: #{col}"
      end
      pluck(col).map { |id| Card.fetch id }
    end

    def sort args
      return self unless valid_sort_args? args
      if args[:sort_by].to_sym == :importance
        order_by_importance args
      else
        order_by args
      end
    end

    def paging args
      return self unless valid_page_args? args
      limit(args[:limit]).offset(args[:offset])
    end

    def return args={}
      return answer_cards unless args.present?
      val = args.is_a?(Hash) ? args[:return] : args
      return multi_return val if val.is_a? Array

      case val.to_s
      when "value_card"
        value_cards
      when /^(\w+)_card/
        cards Regexp.last_match(1)
      when "count"
        count
      when "name", "answer_name"
        pluck(:record_name, :year).map { |parts| parts.join "+" }
      when "id"
        pluck(:answer_id)
      when *Answer.column_names
        pluck(val)
      else
        if Answer.column_names.include? "#{val}_name"
          pluck("#{val}_name")
        else
          answer_cards
        end
      end
    end

    def uniq_select args={}
      return self unless valid_uniq_select_args? args
      if group_necessary?(args)
        group(args[:uniq])
      elsif args[:return] == :count
        select(args[:uniq]).distinct
      else
        distinct
      end
    end

    private

    def multi_return cols
      cols.map! { |col| col.to_sym.in?(NAME_COLUMNS) ? "#{col}_name" : col }
      pluck(*cols)
    end

    def order_by args
      order order_args(args)
    end

    def order_by_importance args
      args = order_args sort_by: "COALESCE(c.db_content, 0)", cast: "signed",
                        sort_order: args[:sort_order]
      joins("LEFT JOIN cards AS c " \
            "ON answers.metric_id = c.left_id AND c.right_id = #{Card::VoteCountID}")
        .order(args)
    end

    def order_args args
      by = args[:cast] ? "CAST(#{args[:sort_by]} AS #{args[:cast]})" : args[:sort_by]
      "#{by} #{args[:sort_order]}"
    end

    def valid_sort_args? args
      return unless args.present? && args[:sort_by]
      return true if args[:sort_by].to_sym == :importance
      Answer.column_names.include? args[:sort_by].to_s
    end

    def valid_page_args? args
      args.present? && args[:limit].to_i.positive?
    end

    def valid_uniq_select_args? args
      args.present? && args[:uniq]
    end

    def group_necessary? args
      (!args[:return] && args[:uniq] != :answer_id) ||
        (args[:return] != :count && args[:uniq] != args[:return])
    end
  end
end
