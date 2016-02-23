def is_cached_count?
  (r = right) && r.codename == :cached_count
end

event :update_expired_cached_count_cards,
      :integrate, when: proc { |c| !c.is_cached_count? } do
  run_expiry_checks :all
  next unless @action
  run_expiry_checks @action
  next if @action != :create && @action != :update
  run_expiry_checks :save
end

def run_expiry_checks action
  return unless expiry_checks = Card::CachedCount.expiry_checks[action]
  expiry_checks.each do |block|
    if (expired = block.call(self))
      Array.wrap(expired).compact.each do |item|
        next if !item || !item.respond_to?(:update_cached_count)
        item.update_cached_count
      end
    end
  end
end
