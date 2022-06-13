format :html do
  before :title do
    voo.title ||= "Log in"
  end

  def signin_button
    button_tag "Log in", situation: :primary
  end
end
