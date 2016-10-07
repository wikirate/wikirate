format :html do
  view :title do |args|
    "<h5>#{super(args)}</h5>"
  end
end
