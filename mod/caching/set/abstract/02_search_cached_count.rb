include_set Type::SearchType

def self.included host_class
  host_class.include_set Abstract::CachedCount
  host_class
end

def virtual?
  new?
end

def type_id
  SearchTypeID
end
