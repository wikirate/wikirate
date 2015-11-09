
def is_cached_count?
  (r=right) && r.codename == :cached_count
end

event :update_expired_cached_count_cards, :after=>:extend, :when=>proc{ |c| !c.is_cached_count? } do
  run_expiry_checks @action if @action
  run_expiry_checks :all
  if @action == :create || @action == :update
    run_expiry_checks :save
  end
end

def run_expiry_checks action
  Card::CachedCount.expiry_checks[action].each do |block|
    if (expired = block.call(self))
      Array.wrap(expired).compact.each do |item|
        item.update_cached_count if item.respond_to? :update_cached_count
      end
    end
  end
end

