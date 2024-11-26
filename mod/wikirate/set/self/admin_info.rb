format :json do
  view :migrations, perms: :none do
    %w[schema_migrations tranform_migrations].each_with_object({}) do |table, h|
      h[table] = migration_answers table
    end.to_json
  end

  def migration_answers table_name
    sql = "SELECT * FROM #{table_name}"
    ActiveRecord::Base.connection.execute(sql).each.each.map do |answer|
      answer[0]
    end
  end
end
