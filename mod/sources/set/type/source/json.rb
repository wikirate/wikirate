format :json do
  view :atom do
    super().merge file_url: card.file_url
  end
end