format :html do
  view :core do
    dropdown_button fa_icon(:bars), dropdown_items.compact
  end

  def dropdown_items
    content_object.chunks.map do |item|
      case item
      when String
        item.strip!
        dropdown_header item if item.present?
      when ::Card::Content::Chunk::Link
        [item.link_target, item.link_text]
      end
    end
  end
end
