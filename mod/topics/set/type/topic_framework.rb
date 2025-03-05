card_accessor :topic, type: :search_type
card_accessor :category

format :html do
  view :titled_content do
    [
      field_nest(:description),
      field_nest(:category),
      field_nest(:topic, view: :filtered_content)
    ]
  end

  view :bar_right do
    count_badges :topic
  end
end
