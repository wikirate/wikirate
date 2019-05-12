format do
  view :missing do
    # FIXME: codename (or, ideally, a better solution!)
    nest Card["missing image"], view: :core, size: voo.size
  end
end

format :html do
  def invalid_image _source
    render_missing
  end

  view :missing do
    # wrap missing view in slot unless the requested view is core
    # (seems shaky!)  Also...why??
    voo.requested_view == :core ? super() : wrap(false) { super() }
  end
end
