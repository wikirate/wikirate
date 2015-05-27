format :html do

  view :core do |args|
    if args[:structure]
      process_content _render_raw(args)
    else
      handle_source args do |source|
        card_url source
      end
    end
  end

end