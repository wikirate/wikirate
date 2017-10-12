# +checked_by stores the current check state as follows:
# empty/non-existent: no check
# refer to "request": double check is requested
# refer to one or more users: the users checked the value
#
# We have to distinguish between
# "double check currently requested" and
# "double check was requested before it was double checked"
# so that the value can get its "requested" state back if somebody
# removes his double check. We use the +check_requested_by card for that.
# If the double check is requested the requester is
# stored (permanently) in +check_requested_by and +checked_by is set
# to "request". A double check removes the "request" and adds the checker to
# +checked_by but the requester stays in +check_requested_by.

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
  checkers.present?
end

def check_requested?
  items.first == "request"
end

def checkers
  check_requested? ? [] : items
end

def check_requester
  check_requested_by_card && check_requested_by_card.item_names.first
end

def check_requested_by_card
  @check_requested_by_card ||=
    left(new: {}).fetch(trait: :check_requested_by, new: {})
end

def allowed_to_check?
  left.value_card.updater_id != Auth.current_id
end

def check_was_requested_before_double_check?
  check_requester.present?
end

def items
  @items ||= item_names
end

def db_content= content
  @items = nil
  super
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

  def editor
    :checkbox
  end

  def option_label_text _option_name
    "#{request_icon} Request that another researcher double check this value"
  end

  view :core, cache: :never do
    unless card.check_requested? || card.checked? || card.allowed_to_check?
      return ""
    end
    wrap_with :div do
      [
        wrap_with(:h5, "Review"),
        wrap_with(:p, "Does the value accurately represent its source?"),
        check_interaction
      ]
    end
  end

  view :icon, cache: :never do |args|
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
      double_check_buttons
    end
  end

  view :checked_by_list, cache: :never do
    return if card.checkers.empty?
    links = _render_shorter_search_result items: { view: :link }
    %(
      <div class="padding-top-10">
        <i>#{links} <span>checked the value</span></i>
      </div>
    )
  end

  view :shorter_search_result, cache: :never do
    render_view = voo.show?(:link) ? :link : :name
    items = card.checkers
    total_number = items.size
    return "" if total_number.zero?

    fetch_number = [total_number, 4].min
    result = ""
    if fetch_number > 1
      result += items[0..(fetch_number - 2)].map do |c|
        subformat(c).render(render_view)
      end.join(" , ")
      result += " and "
    end

    result +
      if total_number > fetch_number
        %(<a class="known-card" href="#{card.format.render :url}"> ) \
          "#{total_number - 3} others</a>"
      else
        subformat(items[fetch_number - 1]).render(render_view)
      end
  end

  def double_check_icon opts={}
    add_class opts, "verify-blue"
    opts[:title] = "Value checked"
    icon_tag("check-circle", opts).html_safe
  end

  def request_icon _opts={}
    icon_tag("check-circle-o", class: "request-red", title: "check requested")
      .html_safe
  end

  def data_path
    card.cardname.url_key
  end

  def check_button_text
    card.check_requested? ? request_text : "Double check"
  end

  def request_text
    return unless card.check_requested?
    "Double check #{request_icon} requested by #{card.check_requester}"
  end

  def double_check_buttons
    output [
      request_text,
      check_button,
      fix_button
    ]
  end

  def check_button
    wrap_with(:button, class: "btn btn-default btn-sm _value_check_button",
                       data: { path: data_path }) do
      "Yes, I checked"
    end
  end

  def fix_button
    link_to_card card.left, "No, I'll fix it", class: "btn btn-default btn-sm", path: { view: :edit }
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

event :update_answer_lookup_table_due_to_check_change, :finalize, changed: :content do
  refresh_answer_lookup_entry left_id
end

event :user_checked_value, :prepare_to_store, on: :save, when: :add_checked_flag? do
  add_checker unless user_checked?
  update_user_check_log.add_id left.id
end

event :user_unchecked_value, :prepare_to_store, on: :update, when: :remove_checked_flag? do
  drop_checker
  update_user_check_log.drop_id left.id
end

event :user_requests_check, :prepare_to_store,
      when: :request_check_flag_update? do
  requested_by_content =
    if content == "[[#{request_tag}]]"
      return if check_requester.present?
      "[[#{user.name}]]"
    else
      ""
    end

  attach_subcard check_requested_by_card.name,
                 content: requested_by_content,
                 type_id: PointerID
end

def request_tag
  @request_tag ||= Card.fetch_name(:request)
end

def mark_as_requested
  self.content = "[[#{request_tag}]]"
end

def update_user_check_log
  add_subcard Auth.current.cardname.field_name(:double_checked),
              type_id: PointerID
end

def add_checker
  if check_requested? # override request flag
    self.content = "[[#{user.name}]]"
  else
    add_item user.name
  end
end

def drop_checker
  drop_item user.name
  mark_as_requested if item_names.empty? &&
                       check_was_requested_before_double_check?
end

def add_checked_flag?
  Env.params["set_flag"] == "checked"
end

def remove_checked_flag?
  Env.params["set_flag"] == "not-checked"
end

def request_check_flag_update?
  !add_checked_flag? && !remove_checked_flag?
end

format :json do
  view :essential do
    {
      checks: card.checkers.count,
      check_requested: card.check_requested?
    }
  end
end
