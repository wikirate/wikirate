format :html do
  # def edit_args args
  #  args[:structure] = 'source+*type+*Structure'
  # end
  view :editor do
    with_nest_mode :normal do
      voo.structure = "metric value type edit structure"
      wrap_with :div, class: "source-editor nodblclick" do
        [
          form.hidden_field(:content, class: "card-content"),
          _render_sourcebox,
          _render_core
        ]
      end
    end
  end

  view :sourcebox do
    wrap_with :div, class: "sourcebox" do
      [
        text_field_tag(:sourcebox, nil, placeholder: "source name or http://"),
        button_tag("Add")
      ]
    end
  end
end
