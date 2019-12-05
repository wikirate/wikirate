# remove set members from all lists that reference them upon deletion
event :delist, :prepare_to_store, on: :delete do
  Card.search(type: %i[in pointer list], limit: 0, refer_to: id).each do |referer|
    referer.drop_item name
    add_subcard referer
  end
end
