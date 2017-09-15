event :reset_alias_hash, :finalize do
  Company::Aliase.reset_cache
end