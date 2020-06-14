format :html do
  view :core do
    [field_nest(:description),
     field_nest(:browse_answer_filter, view: :filtered_content, items: { view: :bar })]
  end
end
