format :json do
  view :all, perms: :export_all_ok? do
    voo.show! :all_item_cards
    voo.hide! :paging
    show :molecule, {}
  end

  view :items do
    return super() unless voo.show? :all_item_cards

    [].tap do |items|
      Card.where(type_id: card.id, trash: false).find_each do |card|
        card.include_set_modules
        items << listing(card, view: voo_items_view || :atom)
      end
    end
  end

  def export_all_ok?
    Auth.always_ok?
  end

  def show_paging?
    voo.show? :paging
  end
end
