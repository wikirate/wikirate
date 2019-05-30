def self.included host_class
  host_class.class_eval do
    include_set Abstract::CachedCount
    recount_trigger(host_class) { |changed_card| changed_card }
    self
  end
end
