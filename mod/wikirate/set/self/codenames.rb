format :html do
  # show codename in the title
  view :pointer_items, tags: :unknown_ok do |args|
    i_args = item_args(args)
    joint = args[:joint] || " "
    card.item_cards.map do |i_card|
      title = "#{i_card.name} (#{i_card.codename})"
      wrap_item nest(i_card, i_args.clone.merge(title: title)), i_args
    end.join joint
  end
end
