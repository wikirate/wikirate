# TODO: make sure answer card's cache gets cleared and verification view gets
# updated immediately

event :add_check, :prepare_to_store, on: :save, trigger: :required do
  add_item user.name
  close_flags
end

event :drop_check, :prepare_to_store, on: :update, trigger: :required do
  drop_item user.name
end

def close_flags
  left.open_flag_cards.each do |flag|
    flag.status_card.update content: "closed"
  end
end
