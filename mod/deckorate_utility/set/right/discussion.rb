format :html do
  view :input do
    if card.new?
      text_area :comment, rows: 3
    else
      super()
    end
  end

  view :marker, unknown: :blank do
    return "" unless card.content.present?

    icon_tag :comment, title: "Has comments"
  end
end
