module LookupTable
  def card
    @card ||= Card.fetch send(card_column)
  end

  def delete_on_refresh?
    !card || card.trash
  end

  def refresh *fields
    return delete if delete_on_refresh?
    keys = fields.present? ? fields : attributes.keys
    keys.delete("id")
    keys.each do |method_name|
      new_value = send "fetch_#{method_name}"
      send "#{method_name}=", new_value
    end
    save
  end
end
