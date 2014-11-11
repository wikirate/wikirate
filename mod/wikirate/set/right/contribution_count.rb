format :html do
  view :missing  do |args|
    if card.new_card? and card.left
      Auth.as_bot do
        card.left.update_contribution_count
        card.save!
      end
      render(args[:denied_view], args)
    else
      super(args)
    end
  end
end

view :new  do |args|
  render_missing args
end
