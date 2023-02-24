format :html do
  def navbar_item_views
    %i[my_card sign_in]
  end

  def can_disable_roles?
    false
  end

  view :my_card do
    link_to_mycard nest(Auth.current_card, view: :thumbnail_image, hide: :thumbnail_link)
  end
end
