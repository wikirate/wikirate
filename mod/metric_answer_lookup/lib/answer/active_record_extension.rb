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
      self.return("#{type}_id").map(&:card)
    end

    # @params hash [Hash] key1: dir1, key2: dir2
    def sort hash
      self.tap { sort_by_hash hash if hash.present? }
    end

    def paging args
      return self unless valid_page_args? args
      limit(args[:limit]).offset(args[:offset])
    end

    def return val
      if val.blank?
        answer_cards
      elsif val.is_a? Array
        multi_return val
      else
        standard_return val.to_s
      end
    end

    def normalize_sort_metric_bookmarkers
      sort_by_bookmarkers :metric_id
    end

    def normalize_sort_company_bookmarkers
      sort_by_bookmarkers :company_id
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
      when /^(\w+)_card/
        cards Regexp.last_match(1)
      when *Answer.column_names
        pluck(val)
      else
        raise ArgumentError, "unknown Answer return val: #{val}"
      end
    end

    def sort_by_hash hash
      hash.each do |key, dir|
        order Arel.sql("#{normalize_sort_key key} #{dir}")
      end
    end

    def normalize_sort_key key
      try("normalize_sort_#{key}") || key
    end

    def sort_by_bookmarkers field
      Card::Bookmark.add_sort_join self, "answers.#{field}"
      "cts.value"
    end

    def sort_join_field? sort_value
      sort_value.match?(/\w+\.\w+/)
    end

    def valid_page_args? args
      args.present? && args[:limit].to_i.positive?
    end
  end
end
