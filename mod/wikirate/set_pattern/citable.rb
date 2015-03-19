

def label name
  'All Card with type "Web Source", "File Source" and "Text Source" cards'
end

def prototype_args anchor
  { :name=>anchor }
end

def pattern_applies? card
  card.type_id == Card::SourceFileID || card.type_id == Card::WebpageID || card.type_id == Card::TextSourceID 
end

def follow_label name
  label name
end