format :html do
  def export_views
    { Basic: :titled, Extended: :detailed }
  end
end

format :csv do
  view :detailed do
    voo.show! :detailed_export
    render_titled
  end

  view :core do
    item_cards.map { |item_card| nest item_card, show: :detailed_export }
  end
end
