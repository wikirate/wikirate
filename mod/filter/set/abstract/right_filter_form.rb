format :html do
  view :core, cache: :never do
    filter_fields slot_selector: ".RIGHT-answer.filter_result-view"
  end
end
