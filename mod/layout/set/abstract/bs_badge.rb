format :html do
  def labeled_badge count, label, opts={}
    if count.zero? && !opts[:zero_ok]
      opts[:klass] = [opts[:klass], "disabled-o"].compact.join " "
    end
    color = opts[:color] || "secondary"
    haml :labeled_badge, count: count, label: label, klass: opts[:klass], color: color
  end
end
