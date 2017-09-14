format :html do
  def default_sign_up_args _args
    class_up "signup-link", "btn btn-highlight"
    voo.title = "Join"
  end

  def default_sign_in_args _args
    class_up "signin_link", "btn btn-default"
    voo.title = "Log in"
  end

  def default_sign_out_args _args
    voo.title = "Log out"
  end

  def nav_link_class type
    classy(type)
  end
end
