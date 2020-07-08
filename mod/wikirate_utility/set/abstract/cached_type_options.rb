# in FormHelper, #type_options has a special caching for the type options in filters.
#
# If this mod is included in the type set, it will clear that cache when items are
# added or deleted.

event :clear_cached_type_options, :integrate do
  Card.cache.delete "#{type_code}-TYPE-OPTIONS"
end
