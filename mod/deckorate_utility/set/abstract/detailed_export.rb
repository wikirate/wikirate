
# make sure detailed export is identified in time for export filename
module ShowDetailed
  def show view, _args
    voo.show! :detailed_export if view == "detailed"
    super
  end
end

format :html do
  def export_views
    { Basic: :titled, Extended: :detailed }
  end
end

format do
  def export_filename
    detailed? ? "#{super}-extended" : super
  end
end

format :json do
  include ShowDetailed
end

format :csv do
  include ShowDetailed

  view :detailed do
    voo.show! :detailed_export
    render_titled
  end

  view :core do
    item_cards.map { |item_card| nest item_card, show: :detailed_export }
  end
end
