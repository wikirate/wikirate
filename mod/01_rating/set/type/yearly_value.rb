def year
  cardname.parts[-2]
end

def value
  content
end

format :html do
  view :editor, mod: Type::Phrase::Format
end
