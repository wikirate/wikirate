class << self
  def region_fields field
    Card.search left: { type: :region }, right: field
  end

  def region_lookup field
    @region_lookup ||= {}
    @region_lookup[field] ||= region_fields(field).each_with_object({}) do |card, hash|
      hash[card.left_id] = card.content
    end
  end
end