event :block_file_changing, :before=>:approve, :on=>:update do 
  if real? and db_content_changed? and not db_content_was.empty?
    errors.add :file, "is not allowed to be changed."
  end
end