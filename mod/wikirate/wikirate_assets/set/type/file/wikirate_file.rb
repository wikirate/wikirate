 format :html do
  view :core do
    if voo.structure
      process_content _render_raw
    else
      super()
    end
  end
end
