class Answer
  # module extends the functionality of Answer lookup relations
  module ActiveRecordExtension
    include Card::LookupQuery::ActiveRecordExtension

    def answer_names
      pluck(:metric_id, :company_id, :year).map { |m, c, y| Card::Name[m, c, y.to_s] }
    end

    # def cards type
    #   self.return("#{type}_id").map(&:card)
    # end
    #
    # def return val
    #   if val.blank?
    #     answer_cards
    #   elsif val.is_a? Array
    #     pluck(*val)
    #   else
    #     standard_return val.to_s
    #   end
    # end
    #
    # def uniq_select uniq, retrn
    #   return self unless uniq.present?
    #   if group_necessary? uniq, retrn
    #     group uniq
    #   elsif retrn == :count
    #     select(uniq).distinct
    #   else
    #     distinct
    #   end
    # end
    #
    # private
    #
    # def standard_return val
    #   case val
    #   when "value_card"
    #     value_cards
    #   when "count"
    #     count
    #   when "name", "answer_name"
    #     answer_names
    #   when /^(\w+)_card/
    #     cards Regexp.last_match(1)
    #   when *Answer.column_names
    #     pluck(val)
    #   else
    #     raise ArgumentError, "unknown Answer return val: #{val}"
    #   end
    # end
    #
    # # TODO: either optimize with a join or move out of here
    # def value_cards
    #   left_ids = pluck :answer_id
    #   return [] unless left_ids.present?
    #   Card.search left_id: ["in"] + left_ids, right_id: Card::ValueID
    # end
    #
    # def group_necessary? uniq, retrn
    #   (!retrn && uniq != :answer_id) || (retrn != :count && uniq != retrn)
    # end
  end
end
