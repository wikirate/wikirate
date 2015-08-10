event :block_file_changing, :after=>:write_identifier, :on=>:update , :when=>proc{  |c| c.real? && c.db_content_changed? && !c.db_content_was.empty? } do 
  errors.add :file, "is not allowed to be changed."
end