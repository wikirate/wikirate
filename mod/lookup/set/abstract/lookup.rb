
def lookup_class
  raise StandardError, "must define #lookup_class"
end

def lookup
  lookup_class.where(lookup_column => id).take
end

def lookup_column
  lookup_class.card_column
end
