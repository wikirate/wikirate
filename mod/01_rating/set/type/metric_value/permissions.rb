
def ok_to_create
  permit_value_change :create
end

def ok_to_update
  permit_value_change :update
  if @action_ok && type_id_changed? && !permitted?(:create)
    deny_because you_cant("change to this type (need create permission)")
  end
end

def ok_to_delete
  permit_value_change :delete
end

def permit_value_change action
  if !Auth.signed_in?
    deny_because "You need to be logged in to #{action} this"
  elsif metric_card.designer_assessed? &&
    Auth.current_id != metric_card.metric_designer_card.id
    deny_because "Only the metric designer is allowed to #{action} a value"
  end
end

def rule_description

end
