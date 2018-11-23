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
    mysql_args = "-u#{user}"
    mysql_args += " -p#{password}" if password
    mysql_args += " -h #{host}" if host
    mysql_args
  end

  def host
    ENV["DATABASE_MYSQL_HOST"] || ENV["MYSQL_HOST"] || database_config("host")
  end

  def password
    ENV["DATABASE_MYSQL_PASSWORD"] || ENV["MYSQL_PASSWORD"] || database_config("password")
  end

  def user
    ENV["DATABASE_MYSQL_USERNAME"] || ENV["MYSQL_USER"] || database_config("username")
  end

  def database_config key, env=Rails.env
    Decko.config.database_configuration.dig(env, key)
  end

  def base_dump_path
    File.join Decko.root, "db", "base_seed.db"
  end

  def dump_path
    File.join Decko.root, "db", "seed.db"
  end
end
