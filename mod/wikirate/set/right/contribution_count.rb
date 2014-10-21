format :html do
  view :missing  do |args|
    card.left.update_contribution_count
    render(args[:denied_view],args)
  end
end