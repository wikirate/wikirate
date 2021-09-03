# lookup table to optimize complex card systems
#
# TODO: make this a class and have lookup classes inherit from it
module LookupTable
  def self.included host_class
    host_class.extend LookupTable::ClassMethods
    host_class.define_main_fetcher
  end

  def card_column
    self.class.card_column
  end

  def card
    @card ||= Card.fetch send(card_column), look_in_trash: true
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

    refresh_fields fields
    raise Card::Error, "invalid #{self.class} lookup" if invalid?

    save!
  end

  def refresh_fields fields=nil
    keys = fields.present? ? fields : attribute_names
    keys.delete("id")
    keys.each { |method_name| refresh_value method_name }
  end

  def refresh_value method_name
    send "#{method_name}=", send("fetch_#{method_name}")
  end

  def method_missing method_name, *args, &block
    if card.respond_to? method_name
      card.send method_name, *args, &block
    else
      super
    end
  end

  def respond_to_missing? *args
    card.respond_to?(*args) || super
  end

  def is_a? klass
    klass == Card || super
  end
end
