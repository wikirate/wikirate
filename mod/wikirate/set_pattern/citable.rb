

def label name
  'all citable sources'
end

def prototype_args anchor
  { :name=>"*dummy", :type_id => Card::SourceFileID }
end

def pattern_applies? card
  card.type_id == Card::SourceFileID || card.type_id == Card::WebpageID || card.type_id == Card::TextSourceID 
end

def follow_label name
  label name
end