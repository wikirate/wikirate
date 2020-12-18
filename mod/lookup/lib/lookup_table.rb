module LookupTable
  def self.included host_class
    host_class.extend LookupTable::ClassMethods
  end

  def card_column
    self.class.card_column
  end

  def card
    @card ||= Card.fetch send(card_column)
  end

  def card_id
    send card_column
  end

  def card_id= id
    send "#{card_column}=", id
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
