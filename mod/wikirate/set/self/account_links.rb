format :html do
  def navbar_item_views
    %i[my_card sign_in]
  end

  def can_disable_roles?
    false
  end

  def account_dropdown_label
    nest Auth.current_card, view: :thumbnail_image, hide: :thumbnail_link
  end

  def account_dropdown_items
    [[Auth.current, "View profile"],
     [Auth.current, "Account settings", { path: { tab: :profile_account } }],
     [:signin, t("account_sign_out"), { path: { action: :delete } }]]
  end
end
