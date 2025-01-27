format :html do
  wrapper :styled_email do
    haml :styled, body: interior
  end

  view :core, wrap: :styled_email do
    super()
  end

  view :email_css, cache: :yes do
    [:all, :style, :asset_output].card.file.file.read.force_encoding "UTF-8"
  end
end
