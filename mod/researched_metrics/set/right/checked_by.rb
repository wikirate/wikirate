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

event :update_answer_lookup_table_checked_by, :finalize, changed: :content do
  update_answer answer_id: left_id unless left.action == :create
end

event :user_checked_value, :prepare_to_store, on: :save, when: :add_checked_flag? do
  add_checker unless user_checked?
  update_user_check_log.add_id left.id
end

event :user_unchecked_value, :prepare_to_store,
      on: :update, when: :remove_checked_flag? do
  drop_checker
  update_user_check_log.drop_id left.id
end

event :user_requests_check, :prepare_to_store,
      when: :request_check_flag_update?, changed: :content do
  if content == "[[#{request_tag}]]"
    attach_request "[[#{user.name}]]" unless check_requester.present?
  else
    attach_request ""
  end
end

def virtual?
  left.present?
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

def checker_count
  @checker_count ||= checkers.size
end

def check_requester
  check_requested_by_card&.first_name
end

def check_requested_by_card
  @check_requested_by_card ||=
    left(new: { type_id: Card::MetricAnswerID }).check_requested_by_card
end

def allowed_to_check?
  Auth.current_id != answer&.value_card&.content_updater_id
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

def answer
  @answer ||= left&.answer
end

def main_action?
  Director.act&.card == self
end

def attach_request requester
  attach_subcard check_requested_by_card.name,
                 content: requester, type_id: Card::PointerID
end

def request_tag
  @request_tag ||= Card.fetch_name(:request)
end

def mark_as_requested
  self.content = "[[#{request_tag}]]"
end

def update_user_check_log
  add_subcard Auth.current.name.field_name(:double_checked),
              type_id: Card::PointerID
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
  Env.params["set_flag"] == "check"
end

def remove_checked_flag?
  Env.params["set_flag"] == "uncheck"
end

def request_check_flag_update?
  !add_checked_flag? && !remove_checked_flag?
end

