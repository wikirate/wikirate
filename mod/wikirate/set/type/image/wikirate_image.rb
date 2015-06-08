view :missing do |args|
  if home_view = args[:home_view] and home_view == :source
    # to get the wikirate icon
    Card["*logo"].format.render_source args.merge({:size=>"large"})
  else
    super args
  end
end
