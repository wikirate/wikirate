format :html do
  view :company_name do
    nest card.cardname.right, view: :thumbnail
  end

  view :value do
    card.content
  end
end
