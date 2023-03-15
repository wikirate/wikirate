format :html do
  view :core do
    dropdown_button icon_tag(:nav_menu), title: "Navigation Menu" do
      dropdown_items.compact
    end
  end

  private

  def dropdown_items
    content_object.chunks.map do |item|
      case item
      when String
        dropdown_string_item item
      when ::Card::Content::Chunk::Link
        dropdown_link_item item
      end
    end
  end

  def dropdown_string_item item
    item.strip!
    dropdown_header item if item.present?
  end

  def dropdown_link_item item
    [item.link_target, item.link_text]
  end
end
