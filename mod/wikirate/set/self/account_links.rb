format :html do
  def navbar_item_views
    %i[my_card sign_in]
  end

  def can_disable_roles?
    false
  end

  # view :my_card do
  #   "woot"
  # end

  # view :sign_in do
  #   "what?"
  # end
end
