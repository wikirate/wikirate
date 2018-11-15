format :html do
  view :sourcebox do
    wrap_with :div, class: "sourcebox" do
      [
        text_field_tag(:sourcebox, nil, placeholder: "keyword or http://"),
        button_tag("Add")
      ]
    end
  end
end
