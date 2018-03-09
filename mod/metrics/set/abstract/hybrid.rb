def hybrid?
  hybrid_card.checked?
end

format :html do
  view :content_formgroup do
    super() + field_nest(:hybrid, title: "Hybrid")
  end
end
