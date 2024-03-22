format :html do
  view :descendant_core do
    [wrap_with(:h6) { "Inherit from ancestor (in order of precedence):" },
     ancestor_thumbnails]
  end

  def descendant_input
    filtered_list_input
  end

  def descendant_filtered_item_view
    implicit_item_view
  end

  def descendant_filtered_item_wrap
    :filtered_list_item
  end

  private

  def ancestor_thumbnails
    accordion do
      card.item_cards.map do |metric|
        metric_accordion_item metric do
          nest metric, view: :thumbnail
        end
      end
    end
  end
end
