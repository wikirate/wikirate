module LookupTable
  def card
    @card ||= Card.fetch send(card_column)
  end

  def refresh *fields
    return delete if !card || card.trash || invalid?
    keys = fields.present? ? fields : attributes.keys
    keys.delete("id")
    keys.each do |method_name|
      new_value = send "fetch_#{method_name}"
      send "#{method_name}=", new_value
    end
    save
  end
end
