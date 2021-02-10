def lookup_class
  raise StandardError, "must define #lookup_class"
end

def lookup
  lookup_class.for_card id
end
