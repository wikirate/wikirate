module LookupTable
  def card
    @card ||= Card.fetch send(card_column)
  end

  def refresh *fields
    # when we override a hybrid metric the answer is invalid because of the
    # missing answer_id, so we check `invalid?` only for non-hybrid metrics)
    return delete if !card || card.trash || (!metric_card&.hybrid? && invalid?)
    keys = fields.present? ? fields : attributes.keys
    keys.delete("id")
    keys.each do |method_name|
      new_value = send "fetch_#{method_name}"
      send "#{method_name}=", new_value
    end
    save
  end
end
