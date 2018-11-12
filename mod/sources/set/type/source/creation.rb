format :html do
  # view :new do
  #  preview? ? _render_new_preview : super()
  # end

  # def preview?
  #   return false if @previewed
  #   @previewed = true
  #   Env.params[:preview]
  # end

  # view :new_preview, cache: :never, tags: :unknown_ok do
  #   with_nest_mode :edit do
  #     voo.structure = "metric value source form"
  #     voo.type = "source"
  #     card_form :create, "main-success": "REDIRECT",
  #                        "data-form-for": "new_metric_answer",
  #                        class: "card-slot new-view TYPE-source" do
  #       output [preview_hidden,
  #               new_view_type,
  #               _render_content_formgroup,
  #               _render_preview_buttons]
  #     end
  #   end
  # end

  # def new_view_hidden
  #   hidden_tags success: {
  #     id: "_self", soft_redirect: true, view: :source_and_preview
  #   }
  # end

  # view :preview_buttons do
  #   button_formgroup do
  #     wrap_with :button, "Add and preview", class: "btn btn-primary pull-right",
  #                                           data: { disable_with: "Adding" }
  #   end
  # end

  # def preview_hidden
  #   hidden_field_tag "card[subcards][+company][content]", Env.params[:company]
  # end
end
