module LookupTable
  module ClassMethods
    VALUE_JOINT = Card::Set::Abstract::Value::JOINT

    attr_reader :card_column,
                :card_query # wql that finds all items in the cards table

    def new_for_card cardish
      ma = new # to document: why can't answer_id be assigned in new?
      ma.card_id = Card.id cardish
      ma
    end

    def create cardish
      new_for_card(cardish).refresh
    end

    def create! cardish
      ma = new_for_card cardish
      raise ActiveRecord::RecordInvalid, ma if ma.invalid?
      ma.refresh
    end

    def create_or_update cardish, *fields
      ma_card_id = Card.id cardish
      ma = find_by_card_id(ma_card_id) || new_for_card(ma_card_id)
      fields = nil if ma.new_record? # update all fields if record is new
      ma.refresh(*fields)
    end

    def find_by_card_id card_id
      card_id ? where(card_column => card_id).take : nil
    end

    # @param ids [Array<Integer>] ids of answers in the answer table (NOT card ids)
    def update_by_ids ids, *fields
      Array(ids).each do |id|
        next unless (answer = Answer.find_by_id(id))
        answer.refresh(*fields)
      end
    end

    # @param ids [Integer, Array<Integer>] card ids of metric answer cards
    def refresh ids=nil, *fields
      Array(ids).compact.each do |ma_id|
        refresh_entry fields, ma_id
      end
    end

    def refresh_entry fields, card_id
      if Card.exists? card_id
        create_or_update card_id, *fields
      else
        delete_for_card_id card_id
      end
    rescue StandardError => e
      raise e, "failed to refresh #{name} lookup table " \
               "for card id #{card_id}: #{e.message}"
    end

    def delete_for_card_id card_id
      find_by_card_id(card_id)&.destroy
    end

    def refresh_all fields
      count = 0
      Card.where(card_query).pluck_in_batches(:id) do |batch|
        count += batch.size
        puts "#{batch.first} - #{count}"
        refresh(batch, *fields)
      end
    end

    def unknown? val
      val.to_s.casecmp("unknown").zero?
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
  end
end
