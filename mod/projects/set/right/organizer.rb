format :html do
  view :credit, unknown: true do
    return "" unless card.known?
    wrap_with :div, class: "organized-by horizontal-list text-muted font-weight-normal" do
      [
        wrap_with(:span, "Organized by "),
        render(:core, items: { view: :link })
      ]
    end
  end
end
