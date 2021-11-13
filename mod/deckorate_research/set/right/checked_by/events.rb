# TODO: refactor to use triggers!

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
      on: :save, when: :request_check_flag_update?, changed: :content do
  if content == "[[#{request_tag}]]"
    attach_request "[[#{user.name}]]" unless check_requester.present?
  else
    attach_request ""
  end
end

def update_user_check_log
  add_subcard Auth.current.name.field_name(:double_checked),
              type_id: Card::PointerID
end

def attach_request requester
  attach_subcard check_requested_by_card.name,
                 content: requester, type_id: Card::PointerID
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
  mark_as_requested if item_names.empty? && check_was_requested_before_double_check?
end

def mark_as_requested
  self.content = "[[#{request_tag}]]"
end

def add_checked_flag?
  Env.params[:set_flag] == "check"
end

def remove_checked_flag?
  Env.params[:set_flag] == "uncheck"
end

# this is a terrible test for this. should be an explicit request!
def request_check_flag_update?
  !add_checked_flag? && !remove_checked_flag?
end

def request_tag
  @request_tag ||= Card.fetch_name(:request)
end
