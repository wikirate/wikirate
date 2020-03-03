event :set_search_content, after: :set_content do
  self.search_content = generate_search_content
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
  structure ? content_for_search_from_structure : content
end

def content_for_search_from_structure
  nest_chunks.map do |chunk|
    chunk.referee_card&.content
  end.compact.join "\n"
end
