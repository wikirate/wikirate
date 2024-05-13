def ok_to_update?
  Card::Auth.always_ok?
end
