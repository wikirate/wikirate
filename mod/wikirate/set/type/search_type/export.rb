format :json do
  view :export do |args|
    # render_atom(args)
    if card.content.empty? || card.name.include?("+*options") ||
       card.name.include?("+*structure")
      render_atom(args)
    else
      super(args)
    end
  end

  view :export_items do |args|
    card.item_names(limit: 5).map do |i_name|
      next unless (i_card = Card[i_name])
      subformat(i_card).render_atom(args)
    end.flatten.reject { |c| (c.nil? || c.empty?) }
  end
end
