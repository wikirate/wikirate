event :block_file_changing, :after=>:write_identifier, :on=>:update do 
  if real? && db_content_changed? && !db_content_was.empty?
    errors.add :file, "is not allowed to be changed."
  end
end