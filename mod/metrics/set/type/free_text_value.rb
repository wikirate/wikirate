include_set Abstract::Value

format :html do
  view :editor do
    text_field :content, class: "d0-card-content"
  end

  def pretty_value
    @pretty_value ||= card.value
  end
end
