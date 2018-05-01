format :html do
  before :sign_up do
    class_up "signup-link", "btn btn-highlight"
    voo.title = "Join"
  end

  before :sign_in do
    class_up "signin_link", "btn btn-outline-secondary"
    voo.title = "Log in"
  end

  before :sign_out do
    voo.title = "Log out"
  end

  def nav_link_class type
    classy(type)
  end
end
