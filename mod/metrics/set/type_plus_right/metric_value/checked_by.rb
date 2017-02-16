# a pointer hack:
# If the first item is "request" then the second item is the requester
# and all users after that are checkers

def unknown?
  false
end

def user
  Auth.current
end

def user_checked?
  checked? && checkers.include?(user.name)
end

def other_user_requested_check?
  check_requested? && check_requester != user.name
end

def checked?
  !check_requested? && checkers.present?
end

def check_requested?
  items.first == "request" && items.size <= 2
end

def checkers
  check_requested? ? items[2..-1] : items
end

def check_requester
  items.second
end

def items
  @items ||= item_names
end

def option_names
  ["request"]
end

format :html do
  view :edit_in_form do
    with_relative_names_in_form do
      card.other_user_requested_check? ? "" : super()
    end
  end

  def part_view
    :checkbox
  end

  def option_label_text _option_name
    "#{request_icon} Request that another researcher double checks this value"
  end

  view :core do
    wrap_with :div do
      [
        wrap_with(:p, "Does the value accurately represent its source?"),
        check_interaction
      ]
    end
  end

  view :icon do |args|
    if card.checked?
      double_check_icon args
    elsif card.check_requested?
      request_icon args
    else
      ""
    end
  end

  def check_interaction
    if card.user_checked?
      user_checked_text
    elsif card.checked?
      _render_checked_by_list
    else
      check_button
    end
  end

  view :checked_by_list do
    return if card.checkers.empty?
    links = subformat(card).render_shorter_search_result items: { view: :link }
    %(
      <div class="padding-top-10">
        <i>#{links} <span>checked the value</span></i>
      </div>
    )
  end

  def double_check_icon opts={}
    add_class opts, "verify-blue"
    opts[:title] = "Value checked"
    icon_tag("check-circle", opts).html_safe
  end

  def request_icon _opts={}
    icon_tag("check-circle-o", class: "request-red", title: "check requested").html_safe
  end

  def data_path
    card.cardname.url_key
  end

  def check_button_text
    text = "Double check"
    return text unless card.check_requested?
    text << " #{request_icon} requested by #{card.check_requester}"
    text
  end

  def check_button
    button_class = "btn btn-default btn-sm _value_check_button hover-button"
    wrap_with(:button, class: button_class,
              data: { path: data_path }) do
      output [
               wrap_with(:span, check_button_text, class: "text"),
               wrap_with(:span, "Yes, I checked the value", class: "hover-text")
             ]
    end
  end

  def check_button_request_credit
    return unless card.check_requested?
    " #{request_icon} requested by #{card.check_requester}"
  end

  def user_checked_text
    icon_class = "fa fa-times-circle-o fa-lg cursor-p _value_uncheck_button"
    output [
             wrap_with(:i, '"Yes, I checked the value"'),
             wrap_with(:i, "", class: icon_class, data: { path: data_path })
           ]
  end
end

def update_user_check_log
  add_subcard Auth.current.cardname.field_name(:double_checked),
              type_id: PointerID
end

event :update_answer_lookup_table_due_to_check_change, :finalize,
      changed: :content do
  refresh_answer_lookup_entry left_id
end

event :user_checked_value, :prepare_to_store,
      on: :update, when: :add_checked_flag? do
  add_item user.name, true unless user_checked?
  update_user_check_log.add_id left_id
end

event :user_unchecked_value, :prepare_to_store,
      on: :update, when: :remove_checked_flag? do
  drop_checker user.name if user_checked?
  update_user_check_log.drop_id left_id
end

event :user_requests_check, :prepare_to_store do
  if content == "[[request]]"
    self.content = ["request", user.name].to_pointer_content
  end
end

def drop_checker user
  if check_requested? && requester == user
    insert_item user, 1 # deletes all other occurences
  else
    drop_item user
  end
end

def add_checked_flag?
  Env.params["set_flag"] == "checked"
end

def remove_checked_flag?
  Env.params["set_flag"] == "not-checked"
end
