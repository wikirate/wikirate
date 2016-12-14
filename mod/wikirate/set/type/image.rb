view :missing do |args|
  core = subformat(Card["missing image"])._render_core args
  if @denied_view == :core
    core
  else
    wrap(false) { core }
  end
end

format :email_html do
  view :raw do |args|
    args[:attachments].inline[card.key] = card.attachment.path
    image_tag args[:attachments][card.key].url
  end
end
