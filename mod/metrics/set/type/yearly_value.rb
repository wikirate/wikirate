def year
  cardname.parts[-2]
end

def value
  content
end

format :html do
  def editor
    :text_field
  end
end
