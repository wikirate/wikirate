include_set Abstract::LookupField

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

delegate :check_requested_by_card, to: :answer_card

def lookup_columns
  %i[check_requester checkers verification]
end

def virtual?
  left.present?
end

def user
  Auth.current
end

def verification
  symbol = verification_symbol
  Answer.verification_index symbol if symbol
end

def verification_symbol
  if steward_verified?
    :steward_verified
  elsif check_requested?
    :flagged
  elsif checkers.any?
    :community_verified
  end
end

def steward_verified?
  (item_ids & answer_card.steward_ids).any?
end

def user_checked?
  checked? && checkers.include?(user.name)
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

def answer_card
  @answer_card ||= left new: { type_id: Card::MetricAnswerID }
end

def answer
  @answer ||= left&.answer
end
