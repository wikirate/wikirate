include_set Abstract::MetricChild, generation: 3

format :html do
  view :company_name do
    nest card.cardname.right, view: :thumbnail
  end

  view :inverse_company_name do
    nest card.company_card, view: :thumbnail
  end

  view :value do
    card.content
  end
end
