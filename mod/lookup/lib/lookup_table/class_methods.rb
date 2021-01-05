module LookupTable
  # shared class methods for lookup tables.
  module ClassMethods
    attr_reader :card_column,
                :card_query # cql that finds all items in the cards table

    def for_card cardish
      card_id = Card.id cardish
      card_id ? where(card_column => card_id).take : nil
    end
    alias_method :find_for_card, :for_card

    def new_for_card cardish
      new.tap do |lookup|
        lookup.card_id = Card.id cardish
      end
    end

    # TODO: change to create_for_card for consistency
    def create cardish
      new_for_card(cardish).refresh
    end

    def create! cardish
      lookup = new_for_card cardish
      raise ActiveRecord::RecordInvalid, lookup if lookup.invalid?
      lookup.refresh
    end

    def create_or_update cardish, *fields
      lookup = for_card(cardish) || new_for_card(cardish)
      fields = nil if lookup.new_record? # update all fields if record is new
      lookup.refresh(*fields)
    end

    # @param ids [Array<Integer>] ids of answers in the answer table (NOT card ids)
    def update_by_ids ids, *fields
      Array(ids).each do |id|
        next unless (entry = find_by_id(id))
        entry.refresh(*fields)
      end
    end

    def delete_for_card cardish
      for_card(cardish)&.destroy
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
        delete_for_card card_id
      end
    rescue StandardError => e
      raise e, "failed to refresh #{name} lookup table " \
               "for card id #{card_id}: #{e.message}"
    end

    def refresh_all fields=nil
      count = 0
      Card.where(card_query).pluck_in_batches(:id) do |batch|
        count += batch.size
        puts "#{batch.first} - #{count}"
        refresh(batch, *fields)
      end
    end

    # define standard lookup fetch methods.
    #
    # Eg. fetcher(:company_id) defines #fetch_company_id to fetch from card.company_id
    #
    # And fetcher(foo: :bar) defines #fetch_foo to fetch from card.bar
    def fetcher *args
      fetcher_hash(*args).each { |col, method| define_fetch_method col, method }
    end

    def define_main_fetcher
      define_fetch_method @card_column, :id
    end

    private

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
