format :html do
  view :comments do |_args|
    disc_card = card.fetch trait: :discussion, new: {}
    subformat(disc_card)._render_titled title: "Comments", show: "commentbox",
                                        home_view: :titled
  end

  view :credit_name do |args|
    wrap_with :div, class: "credit" do
      [
        "#{credit_verb} #{_render_updated_at} ago by ",
        nest(card.updater, view: :link),
        _render(:source_link, args, :hide)
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
    source_card = card.fetch trait: :source
    source_options = { view: :core, items: { view: :cited } }
    source_options[:items][:hide] = :cited_source_links if voo.hide? :cited_source_links
    output [
      wrap_with(:h5, "Citations (#{source_card.item_names.size})"),
      nest(source_card, source_options)
    ]
  end

  view :sources_with_cited_button do
    with_nest_mode :normal do
      field_nest :source, view: :core, items: { view: :with_cited_button }
    end
  end

  def default_value_link_args _args
    voo.hide! :link if card.relationship?
  end

  view :value_link do
    voo.show :link
    text = beautify(pretty_value)
    wrap_with :span, class: "metric-value" do
      if voo.hide? :link
        text
      else
        link_to(text, path: "/#{card.name.url_key}", target: "_blank")
      end
    end
  end

  def beautify value
    card.scored? ? beautify_scored(value) : value
  end

  def beautify_scored value
    value = shorten_score value
    colorify(value)
  end

  def shorten_score value
    return value if value.number?
    Answer.unknown?(value) ? "?" : "!"
  end

  def pretty_value
    @pretty_value ||= numeric_value? ? humanized_value : value
  end

  def grade
    return unless (value = card&.value&.to_i)
    case value
    when 0, 1, 2, 3 then :low
    when 4, 5, 6, 7 then :middle
    when 8, 9, 10 then :high
    end
  end

  def numeric_value?
    return false unless card.metric_card.numeric?
    !card.value_card.unknown_value?
  end

  def value
    card.value_card.value
  end

  def raw_value
    value
  end

  def humanized_value
    card.value_card.item_names.map { |n| humanized_number n }.join ", "
  end
end
