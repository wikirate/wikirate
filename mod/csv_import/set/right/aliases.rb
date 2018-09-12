event :reset_alias_hash, :finalize do
  Company::Alias.reset_cache
end

format :html do
  def default_item_view
    :name
  end
end
