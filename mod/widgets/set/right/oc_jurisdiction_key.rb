


def oc_code
  content.to_sym
end

event :clear_jurisdiction_key_cache do
  ::OpenCorporates::RegionCache.cache.reset_all
end
