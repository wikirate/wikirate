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
      ma =
          MetricAnswer.find_by_metric_answer_id(ma_card_id) ||
        MetricAnswer.new
      ma.metric_answer_id = ma_card_id
      ma.refresh
    end

    def fetch args
      MetricAnswer.where(args).pluck(:metric_answer_id).map do |id|
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
    latest_to_false if latest
    save
  end

  def delete
    super.tap do
      latest_year = latest_year_in_db
      MetricAnswer.where(metric_record_id: metric_record_id, year: latest_year)
          .update_all(latest: true)
    end
  end

  def latest_to_false
    MetricAnswer.where(metric_record_id: metric_record_id, latest: true)
        .update_all(latest: false)
  end
end
