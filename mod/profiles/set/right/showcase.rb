format :html do
  view :open do
    if (l = card.left) &&
       (Auth.current_id == l.id || l.type_code == :wikirate_company)
      class_up "card-slot", "editable"
    end
    super()
  end
end
