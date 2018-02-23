format :html do
  def bs_badge count, label, opts={}
    opts[:klass] = "disabled-o" if count.zero? && !opts[:zero_ok]
    opts[:color] = "secondary" unless opts[:color]
    haml :bs_badge, count: count, label: label, klass: opts[:klass], color: opts[:color]
  end
end
