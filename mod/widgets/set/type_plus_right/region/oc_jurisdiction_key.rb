def oc_code
  content.to_sym
end

event :clear_jurisdiction_key_cache do
  Card::Region.cache.reset_all
end
