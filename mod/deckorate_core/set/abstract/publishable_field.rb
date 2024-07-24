def ok_to_read?
  super && (new? || left&.check_published)
end
