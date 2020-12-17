module LookupTable
  module ClassMethods
    attr_reader :card_column,
                :card_query # cql that finds all items in the cards table

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
        next unless (entry = find_by_id(id))
        entry.refresh(*fields)
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

    def refresh_all fields=nil
      count = 0
      Card.where(card_query).pluck_in_batches(:id) do |batch|
        count += batch.size
        puts "#{batch.first} - #{count}"
        refresh(batch, *fields)
      end
    end

    def fetcher *args
      fetcher_hash(*args).each { |col, method| define_fetch_method col, method }
    end

    def define_fetch_method column, card_method
      define_method "fetch_#{column}" do
        card.send card_method
      end
    end

    def fetcher_hash *args
      if args.first.is_a?(Hash)
         args.first
       else
         args.each_with_object({}) { |item, h| h[item] = item }
       end
    end
  end
end
