event :set_search_content, after: :set_content do
  self.search_content = generate_search_content
end

event :trigger_left_search_content_update, after: :set_search_content do
  return unless name.junction?
  l = left

  return unless l&.real? && l.search_content_field_names&.include?(name)

  l.set_search_content
  l.save if l.search_content_changed?
end

def generate_search_content
  tagless do
    [name_for_search, content_for_search].compact.join "\n"
  end
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

  nest_chunks.map { |chunk| chunk.referee_card }.compact
end

def search_content_field_names
  search_content_cards.map(&:name)
end

def content_for_search_from_fields
  search_content_cards.map(&:content).compact.join "\n"
end
