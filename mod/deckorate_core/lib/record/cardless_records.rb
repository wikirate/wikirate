class Record
  # Methods to handle records that exist only in the the record table
  # and don't have a card. Used for calculated records.
  module CardlessRecords
    def card_without_record_id name=nil, val=nil
      fetch_record_card(name).tap do |card|
        if card.id
          update! record_id: card.id
        else
          virtualize card, val
        end
      end
    end

    # true if there is no card for this record
    def virtual?
      card&.virtual?
    end

    private

    def fetch_record_card name=nil
      name ||= record_name_from_parts
      Card.fetch name, eager_cache: true, new: { type_id: Card::RecordID }
    end

    def record_name_from_parts
      [metric_id, company_id, year.to_s]
    end

    def virtualize vcard, val=nil
      val ||= value
      vcard.tap do |card|
        card.define_singleton_method(:virtual?) { true }
        card.define_singleton_method(:value) { val }
        # card.define_singleton_method(:updated_at) { updated_at }
        card.define_singleton_method(:value_card) { virtual_value_card val }
        card.record = self
      end
    end
  end
end
