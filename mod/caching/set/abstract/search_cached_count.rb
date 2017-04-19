def self.included host_class
  host_class.include_set Abstract::CachedCount
  host_class.include_set Abstract::WqlSearch
  host_class
end

def virtual?
  true
end

def type_id
  SearchTypeID
end
