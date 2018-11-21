namespace :wikirate do
  def dump path, db=db_name
    execute_command "mysqldump #{mysql_login} #{db} > #{path}"
  end

  def db_name
    Decko.config.database_configuration.dig(Rails.env, "database")
  end

  def load_dump path, db=db_name
    cmd = "echo \"create database if not exists #{db} " \
          "character set utf8mb4 COLLATE utf8mb4_unicode_ci\" "\
          "| mysql #{mysql_login}; " \
          "mysql #{mysql_login} --database=#{db} < #{path}"
    # puts "executing #{cmd}"
    system cmd
  end

  def mysql_login
    user = ENV["DATABASE_MYSQL_USERNAME"] || ENV["MYSQL_USER"] || "root"
    pwd  = ENV["DATABASE_MYSQL_PASSWORD"] || ENV["MYSQL_PASSWORD"]
    mysql_args = "-u #{user}"
    mysql_args += " -p #{pwd}" if pwd
    mysql_args += " -h #{host}" if host
    mysql_args
  end

  def host
    Decko.config.database_configuration.dig(Rails.env, "host")
  end

  def base_dump_path
    File.join Decko.root, "db", "base_seed.db"
  end

  def dump_path
    File.join Decko.root, "db", "seed.db"
  end
end
