card_accessor :topic, type: :search_type
card_accessor :category

format :html do
  view :titled_content, template: :haml

  view :bar_right do
    count_badges :topic
  end
end
