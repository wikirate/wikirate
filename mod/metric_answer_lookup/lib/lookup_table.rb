module LookupTable
  def card
    @card ||= Card.fetch send(card_column)
  end

  module ClassMethods
    def create card
      ma = MetricAnswer.new
      ma.metric_answer_id = card.id
      ma.refresh
    end

    def create_or_update cardish
      ma_card_id = card_id(cardish)
      ma = MetricAnswer.find_by_metric_answer_id(ma_card_id) ||
        MetricAnswer.new
      ma.metric_answer_id = ma_card_id
      ma.refresh
    end

    def fetch where, sort={}, paging={}
      where = Array.wrap where
      mas = MetricAnswer.where(*where)
      if sort.present?
        sort_by = sort[:sort_by]
        sort_by = "CAST(#{sort_by} AS #{sort[:cast]})" if sort[:cast]
        mas = mas.order "#{sort_by} #{sort[:sort_order]}"
      end
      if paging.present?
        mas = mas.limit(paging[:limit]).offset(paging[:offset])
      end
      mas.pluck(:metric_answer_id).map do |id|
        Card.fetch id
      end
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
