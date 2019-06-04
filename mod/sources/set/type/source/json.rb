format :json do
  def atom
    super().merge file_url: nest(card.file_card, view: :core)
  end
end
