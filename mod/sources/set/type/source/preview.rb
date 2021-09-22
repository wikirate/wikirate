format :html do
  # kind of a misleading name - it's a full file view
  view :preview do
    wrap_with :div, class: "nodblclick" do
      nest card.file_card, view: :preview
    end
  end
end
