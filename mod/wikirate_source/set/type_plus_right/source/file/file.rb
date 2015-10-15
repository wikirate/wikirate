card_accessor :metric, :type=>:pointer
card_accessor :year, :type=>:pointer

event :block_file_changing, :after=>:write_identifier, :on=>:update, :changed=>:content,
   :when=>proc{ |c| !c.db_content_was.empty? } do
  errors.add :file, "is not allowed to be changed."
end