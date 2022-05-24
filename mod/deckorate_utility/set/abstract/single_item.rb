format :json do
  view :core do
    card.first_name
  end

  view :content, :core
end
