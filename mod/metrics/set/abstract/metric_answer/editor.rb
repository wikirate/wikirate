format :html do
  view :new, cache: :never do
    # @form_root = true
    subformat(Card[:research_page]).slot_machine
  end

  def default_edit_args _args
    # voo.hide! :toolbar
    voo.hide! :edit_buttons
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
end
