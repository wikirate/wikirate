def is_cached_count?
  (r=right) && r.codename == :cached_count
end

event :update_all_cached_counts_on_delete, :before=>:subsequent do, :when=>proc{ |c| !c.is_cached_count? } do
  run_update_triggers @action
  run_update_triggers :all
  if @action == :create || @action == :update
    run_update_triggers :save
  end
end


