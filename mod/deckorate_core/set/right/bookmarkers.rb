format :html do
  def bookmark_status_class
    card.active? ? "#{card.left.type_name.key}-color" : "inactive-bookmark"
  end
end
