format :html do
  def labeled_badge count, label, opts={}
    haml :labeled_badge, count: count,
                         label: label,
                         klass: opts[:klass],
                         color: opts[:color]
  end
end
