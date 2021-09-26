include_set Abstract::Value

format :html do
  view :input do
    text_field :content, class: "d0-card-content"
  end
end
