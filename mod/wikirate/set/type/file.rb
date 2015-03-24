format :html do
  
  view :core do |args|
    # binding.pry
    if args[:structure]
      process_content _render_raw(args)
    else
      handle_source args do |source|
        "<a href=\"#{source}\">Download #{ showname args[:title] }</a>"
      end
    end
  end

end