format :json do
  def atom
    super().merge(
      file_url: nest(card.file_card, view: :core),
      report_type: card.report_type_card&.first_name
    )
  end
end
