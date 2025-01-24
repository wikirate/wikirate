format :html do
  view :email_css, cache: :yes do
    [:all, :style, :asset_output].card.file.file.read.force_encoding "UTF-8"
  end
end