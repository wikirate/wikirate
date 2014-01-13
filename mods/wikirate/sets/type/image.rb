view :missing do |args|
  core = subformat( Card['missing image'] )._render_core args
  if args[:denied_view] == :core
    core
  else
    wrap( :missing_image, :no_slot=>true ) { core }
  end
end
