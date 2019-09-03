format :html do
  view :input do
    if card.new?
      text_area :comment, rows: 3
    else
      super()
    end
  end

  view :flag, unknown: true do
    return "" unless card.content.present?
    fa_icon :commenting, title: "Has comments"
  end
end
