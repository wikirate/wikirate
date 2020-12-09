class Answer
  module ActiveRecordExtension
    def answer_cards
      map(&:card).compact
    end

    def answer_names
      pluck(:metric_id, :company_id, :year).map { |m, c, y| Card::Name[m, c, y.to_s] }
    end

    # TODO: optimize with a join
    def value_cards
      left_ids = pluck :answer_id
      return [] unless left_ids.present?
      Card.search left_id: ["in"] + left_ids, right_id: Card::ValueID
    end

    def cards type
      self.return("#{type}_id").map &:card
    end

    def sort args
      return self unless valid_sort_args? args
      if args[:sort_by].to_sym == :bookmarkers
        order_by_bookmarkers args[:sort_dir]
      else
        order_by args
      end
    end

    def paging args
      return self unless valid_page_args? args
      limit(args[:limit]).offset(args[:offset])
    end

    def return args={}
      puts "called return with #{args}"

      return answer_cards unless args.present?
      val = args.is_a?(Hash) ? args[:return] : args
      return multi_return val if val.is_a? Array

      standard_return val.to_s
    end

    private

    def multi_return cols
      pluck(*cols)
    end

    def standard_return val
      case val
      when "value_card"
        value_cards
      when "count"
        count
      when "name", "answer_name"
        answer_names
      when *Answer.column_names
        pluck(val)
      when /^(\w+)_card/
        cards Regexp.last_match(1)
      else
        raise ArgumentError, "unknown Answer return val: #{val}"
      end
    end

    def order_by args
      order order_args(args)
    end

    def order_args args
      by = args[:cast] ? "CAST(#{args[:sort_by]} AS #{args[:cast]})" : args[:sort_by]
      # I think it's ok to call Arel.sql here because the arguments coming from params
      # use Query.safe_sql
      Arel.sql "#{by} #{args[:sort_dir]}"
    end

    def order_by_bookmarkers sort_dir
      Card::Bookmark.sort self, "answers.metric_id", sort_dir
    end

    def valid_sort_args? args
      return false unless args.present? && (sort_value = args[:sort_by]&.to_s)

      valid_sort_value_list.include?(sort_value) || sort_join_field?(sort_value)
    end

    def sort_join_field? sort_value
      sort_value.match?(/\w+\.\w+/)
    end

    def valid_sort_value_list
      @valid_sort_value_list ||= Answer.column_names + ["bookmarkers"]
    end

    def valid_page_args? args
      args.present? && args[:limit].to_i.positive?
    end
  end
end
