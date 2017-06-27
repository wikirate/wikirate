format :html do
  view :comments do |_args|
    disc_card = card.fetch trait: :discussion, new: {}
    subformat(disc_card)._render_titled title: "Discussion", show: "commentbox",
                                        home_view: :titled
  end

  view :credit_name do |args|
    wrap_with :div, class: "credit" do
      [
        "#{credit_verb} #{_render_updated_at} ago by ",
        nest(card.updater, view: :link),
        _optional_render(:source_link, args, :hide)
      ]
    end
  end

  def credit_verb
    verb = "updated" # card.answer.editor_id ? "edited" : "added"
    link_to_card card.value_card, verb, path: { view: :history }
  end

  view :source_link do |_args|
    if (source_card = card.fetch(trait: :source))
      source_card.item_cards.map do |i_card|
        subformat(i_card).render_original_icon_link
      end.join "\n"
    else
      ""
    end
  end

  view :sources do
    output [
      wrap_with(:h5, "Cited"),
      subformat(card.fetch(trait: :source)).render_core(items: { view: :cited })
    ]
  end
end
