if respond_to?(:search_content)
  event :set_search_content, after: :set_content do
    self.search_content = tagless { content_for_search.to_s }
  end

  event :trigger_left_search_content_update, after: :set_search_content do
    return unless name.junction?
    l = left

    return unless l&.real? && l.search_content_field_names&.include?(name)

    l.set_search_content
    l.save if l.search_content_changed?
  end

  def tagless
    ::ActionView::Base.full_sanitizer.sanitize yield
  end

  def name_for_search
    name
  end

  def content_for_search
    structure ? content_for_search_from_fields : content
  end

  def search_content_cards
    return [] unless structure && nest_chunks

    nest_chunks.map(&:referee_card).compact
  end

  def search_content_field_names
    search_content_cards.map(&:name)
  end

  def content_for_search_from_fields
    search_content_cards.map(&:content).compact.join "\n"
  end

  format do
    view :search_content do
      card.search_content
    end
  end
end