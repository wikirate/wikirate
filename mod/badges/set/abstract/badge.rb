def add_badge badge_name, cardtype
  name_parts = [Auth.current, cardtype, :badge]
  badge_pointer =
    subcard(name_parts) ||
      attach_subcard(Card.fetch(name_parts, new: { type_id: PointerID }))
  badge_pointer.auto_content = true
  badge_pointer.add_item badge_name
end
