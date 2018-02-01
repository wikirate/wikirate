format :html do
  view :new, cache: :never do
    # @form_root = true
    subformat(Card[:research_page]).slot_machine
  end

  # def default_edit_args _args
  #   # voo.hide! :toolbar
  # end

  view :edit do
    voo.hide! :edit_buttons, :title, :toolbar
    with_nest_mode :edit do
      wrap do
        card_form :update,
                  "main-success" => "REDIRECT",
                  "data-slot-selector": ".card-slot.slot_machine-view",
                  success: research_form_success.merge(view: :slot_machine) do
          output [
                   edit_view_hidden,
                   _render_content_formgroup
                 ]
        end
      end
    end
  end

  view :content_formgroup, template: :haml do
    card.add_subfield :year, content: card.year
    if card.metric_card.relationship?
      card.add_subfield :related_company, content: card.related_company
    end
  end

  def card_form_html_opts action, opts={}
    super
    add_class opts, "answer-form"
    opts
  end

  def menu_path_opts
    super.merge research_params: research_params
  end
end
