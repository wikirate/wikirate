format :html do
  def bs_badge count, label, opts={}
    return if count.zero? && !opts[:zero_ok]
    haml :bs_badge, count: count, label: label, klass: opts[:klass]
  end
end
