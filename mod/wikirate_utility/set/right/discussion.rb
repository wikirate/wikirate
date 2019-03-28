format :html do
  view :editor do
    if card.new?
      text_area :comment, rows: 3
    else
      super()
    end
  end
end
