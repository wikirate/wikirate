format :html do
  view :table_form, cache: :never do |args|
    voo.editor = :inline_nests
    card_form :create, "main-success" => "REDIRECT",
              class: "new-value-form" do
      output [
               new_view_hidden,
               new_view_type,
               render_haml(relevant_sources: _render_relevant_sources(args),
                           cited_sources: _render_cited_sources)
             ]
    end
  end

  view :new_buttons do
    button_formgroup do
      wrap_with :div do
        [
          submit_button(class: "create-submit-button",
                        data: { disable_with: "Adding..." }),
          wrap_with(:button, "Close",
                    type: "button",
                    class: "btn btn-default _form_close_button")
        ]
      end
    end
  end

  def new_view_hidden
    tags =
      { success: { id: "_self", soft_redirect: true, view: :record_list } }
    [:metric, :company, :source].each do |field|
      next unless (value = Env.params[field])
      tags["card[subcards][+#{field}][content]"] = value
    end
    hidden_tags tags
  end
end
