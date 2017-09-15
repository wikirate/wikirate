event :reset_alias_hash, :finalize do
  Company::Alias.reset_cache
end
