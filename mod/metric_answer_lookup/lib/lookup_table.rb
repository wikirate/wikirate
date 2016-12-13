module LookupTable
  def card
    @card ||= Card.fetch send(card_column)
  end

  module ClassMethods
    def create card
      ma = Answer.new
      ma.answer_id = card.id
      ma.refresh
    end

    def create_or_update cardish
      ma_card_id = card_id(cardish)
      ma = Answer.find_by_answer_id(ma_card_id) ||
        Answer.new
      ma.answer_id = ma_card_id
      ma.refresh
    end

    def fetch where, sort_args={}, paging={}
      where = Array.wrap where
      mas = Answer.where(*where)
      mas = sort mas, sort_args if sort_args.present?
      if paging.present?
        mas = mas.limit(paging[:limit]).offset(paging[:offset])
      end
      mas.pluck(:answer_id).map do |id|
        Card.fetch id
      end
    end

    def sort mas, args
      mas = importance_sort mas, args if args[:sort_by] == :importance
      sort_by = args[:sort_by]
      sort_by = "CAST(#{sort_by} AS #{args[:cast]})" if args[:cast]
      mas.order "#{sort_by} #{args[:sort_order]}"
    end

    def importance_sort mas, args
      mas = mas.joins "LEFT JOIN cards AS c " \
                      "ON answers.metric_id = c.left_id " \
                      "AND c.right_id = #{Card::VoteCountID}"
      args.merge! sort_by: "COALESCE(c.db_content, 0)", cast: "signed"
      mas
    end


    def refresh ids=nil
      ids ||= Card.search(type_id: Card::MetricValueID, return: :id)
      ids = Array(ids)
      ids.each do |ma_id|
        create_or_update ma_id
      end
    end

    def card_id cardish
      case cardish
      when Fixnum then
        cardish
      when Card then
        cardish.id
      end
    end
  end

  def refresh
    return delete if !card || card.trash
    keys = attributes.keys
    keys.delete("id")
    keys.each do |method_name|
      new_value = send "fetch_#{method_name}"
      send "#{method_name}=", new_value
    end
    save
  end
end
