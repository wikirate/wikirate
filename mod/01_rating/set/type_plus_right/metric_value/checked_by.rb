def user
  Card.fetch(Auth.current_id)
end

def user_checked_before
  return true if checked_users.include?user.name
end

def checked_users
  item_names
end

format :html do
  # view :new do
  #   return _render_double_check_view
  # end
  view :missing  do |args|
    if card.new_card? && card.left
      Auth.as_bot do
        card.save!
      end
      render(args[:denied_view], args)
    else
      super(args)
    end
  end

  view :open_content do
    _render_double_check_view
  end

  view :double_check_view do
    wrap_with :div do
      [
        content_tag(:h5, double_check_icon + "Double-Check"),
        card.user_checked_before ? checked_content : check_button,
        _render_checked_by_list
      ]
    end
  end

  view :checked_by_list do
    return if card.checked_users.empty?
    %(
      <div class="padding-top-10">
        <i>#{subformat(card).render_shorter_search_result item: :link}
        <span> checked the value </span></i>
      </div>
    )
  end

  def message
    "I checked: value accurately represents source"
  end

  def double_check_icon
    render_haml do
      <<-HAML
%i.fa.fa-check-circle.verify-blue
      HAML
    end
  end

  def data_path
    card.cardname.url_key
  end

  def check_button
    button_class = "btn btn-default btn-sm _value_check_button"
    wrap_with :div do
      [
        content_tag(:span, "Does the value accurately represent its source?"),
        content_tag(:a, "Yes, I checked", class: button_class,
                                          data: { path: data_path })
      ]
    end
  end

  def checked_content
    icon_class = "fa fa-times-circle-o fa-lg cursor-p _value_uncheck_button"
    wrap_with :div, class: "user-checked" do
      [
        content_tag(:span, '"' + message + '"'),
        content_tag(:i, "", class: icon_class, data: { path: data_path })
      ]
    end
  end
end

event :user_checked_value, :prepare_to_store,
      on: :update, when: proc { Env.params["checked"] == "true" } do
  add_item user.name unless user_checked_before
end

event :user_uncheck_value, :prepare_to_store,
      on: :update, when: proc { Env.params["uncheck"] == "true" } do
  drop_item user.name if user_checked_before
end
