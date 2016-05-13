format :json do
  view :export do |args|
    Array.wrap(render_content(args)[:card]).concat(
      render_export_items(args)
    ).flatten
  end

  view :export_items do |args|
    count = args[:count] || 0
    reference_cards.map do |r_card|
      subformat(r_card).render_export(count: count + 1)
    end
  end

  def reference_cards args={}
    content_object = Card::Content.new(_render_raw(args), card)
    content_object.find_chunks(Card::Content::Chunk::Include).map do |chunk|
      chunk.referee_card
    end
  end
end

