format :html do
  view :editor do |args|
    if card.new?
      text_area :comment, rows: 3
    else
      super(args)
    end
  end
end
