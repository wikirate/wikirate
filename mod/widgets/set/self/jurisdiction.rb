format :json do
  view :select2 do
    { results: option_list }.to_json
  end

  def option_list
    Card.search(type_id: JurisdictionID).each_with_object([]) do |i, ar|
      ar << { id: i.key, text: i.name }
    end
  end
end
