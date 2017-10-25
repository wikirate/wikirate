
event :block_file_changing, after: :write_identifier, on: :update, changed: :content,
                            when: proc { |c| !c.db_content_before_act.empty? } do
  errors.add :file, "is not allowed to be changed."
end
