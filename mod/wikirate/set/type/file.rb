format :html do
  
  view :core do |args|
    # binding.pry
    if args[:structure]
      process_content _render_raw(args)
    else
      super args
    end
  end

end