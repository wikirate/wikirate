format :html do
  def default_title_args _args
    voo.title ||= "Log in"
  end

  def signin_button
    button_tag "Log in", situation: :primary
  end
end
