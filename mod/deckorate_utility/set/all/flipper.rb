format :html do
  view :flipper_title do
    render_title
  end

  view :flipper_body do
    render_core
  end
end
