format :html do
  def default_sign_up_args args
    super
    args[:link_opts][:class] = "btn btn-highlight"
    args[:link_text] = "Join"
  end

  def default_sign_in_args args
    super
    args[:link_opts][:class] = "btn btn-highlight"
    args[:link_text] = "Log in"
  end
end
