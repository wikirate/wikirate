include_set Abstract::LookupField

# +checked_by stores the current check state as follows:
# empty/non-existent: unconfirmed
# refer to one or more users: the users who have checked the value

def lookup_columns
  %i[checkers verification]
end

def virtual?
  left.present?
end

def user
  Auth.current
end

def verification
  symbol = verification_symbol
  ::Record.verification_index symbol if symbol
end

def verification_symbol
  if steward_verified?
    :steward_verified
  elsif flagged?
    :flagged
  elsif checkers.any?
    :community_verified
  end
end

def steward_verified?
  (item_ids & record_card.steward_ids).any?
end

def user_checked?
  checked? && checkers.include?(user.name)
end

def checked?
  checkers.present?
end

def flagged?
  (flag_count = lookup&.open_flags).present? && flag_count.positive?
end

def checkers
  items
end

def checker_count
  @checker_count ||= checkers.size
end

def allowed_to_check?
  Auth.current_id != record&.value_card&.content_updater_id
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

def record_card
  @record_card ||= left new: { type_id: Card::RecordID }
end

def record
  @record ||= left&.record
end
