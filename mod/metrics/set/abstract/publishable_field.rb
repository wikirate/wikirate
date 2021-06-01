def ok_to_read
  super && left.check_published
end
