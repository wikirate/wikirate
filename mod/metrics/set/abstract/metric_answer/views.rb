format :html do
  view :comments do
    disc_card = card.fetch trait: :discussion, new: {}
    subformat(disc_card)._render_titled title: "Comments", show: "commentbox",
                                        home_view: :titled
  end

  view :homepage_answer_example, template: :haml do
    @company_image = nest company_card.image_card, size: :small
    @company_link = nest card.answer.company, view: :link
    @metric_image = nest metric_designer_card.image_card, size: :small
    @metric_question = nest card.answer.metric, view: :title_and_question_compact
  end

  view :source_link do
    if (source_card = card.fetch(trait: :source))
      source_card.item_cards.map do |i_card|
        subformat(i_card).render_original_icon_link
      end.join "\n"
    else
      ""
    end
  end

  view :sources do
    source_options = { view: :core, items: { view: :cited } }
    source_options[:items][:hide] = :cited_source_links if voo.hide? :cited_source_links
    output [
      citations_count,
      nest(source_card, source_options)
    ]
  end

  def metric_designer_card
    Card.fetch metric_card.metric_designer
  end

  def source_card
    card.fetch trait: :source
  end

  def citations_count_badge
    wrap_with :span, source_card.item_names.size, class: "badge badge-light border"
  end

  def citations_count
    wrap_with :h5 do
      [
        "Citations",
        citations_count_badge
      ]
    end
  end
  view :sources_with_cited_button do
    with_nest_mode :normal do
      field_nest :source, view: :core, items: { view: :with_cited_button }
    end
  end

  before :value_link do
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
    card.ten_scale? ? beautify_ten_scale(value) : value
  end

  def beautify_ten_scale value
    value = shorten_ten_scale value
    colorify(value)
  end

  def shorten_ten_scale value
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
