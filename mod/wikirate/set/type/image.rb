view :missing do |args|
  core = subformat(Card["missing image"])._render_core args
  if args[:denied_view] == :core
    core
  else
    wrap no_slot: true do core end
  end
end
