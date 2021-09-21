format :html do
  view :sources do
    output [citations_count,
            nest(card.source_card, view: :core, items: { view: :bar })]
  end

  view :source_editor do
    with_nest_mode :normal do
      field_nest :source, view: :core
    end
  end

  view :new_source_form, unknown: true, cache: :never do
    params[:answer] = card.name
    params[:source_url] = source_search_term if source_search_term&.url?
    source_card = Card.new type_id: Card::SourceID
    nest source_card, view: :new
  end

  def wikirate_source_from_url
    mdata = source_search_term.match(%r{//wikirate\.org/(.*)$})
    return unless mdata && (source_card = Card[mdata[1]])
    [source_card]
  end

  def citations_count_badge
    wrap_with :span, card.source_card&.item_names&.size, class: "badge badge-light border"
  end

  def citations_count
    wrap_with :h5, class: "w-100 text-left" do
      [citations_count_badge, "Citations"]
    end
  end
end
