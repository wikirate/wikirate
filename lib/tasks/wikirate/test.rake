require "colorize"
require File.expand_path "../importer", __FILE__

namespace :wikirate do
  namespace :test do
    db_path = File.join Wagn.root, "test", "seed.db"
    testdb = ENV["DATABASE_NAME_TEST"] ||
             ((t = Wagn.config.database_configuration["test"]) &&
             t["database"])
    user = ENV["DATABASE_MYSQL_USERNAME"] || ENV["MYSQL_USER"] || "root"
    pwd  = ENV["DATABASE_MYSQL_PASSWORD"] || ENV["MYSQL_PASSWORD"]

    def execute_command cmd, env=nil
      cmd = "env RAILS_ENV=#{env} #{cmd}" if env
      puts cmd.green
      system cmd
    end

    def import_from location
      FileUtils.rm_rf(Dir.glob("tmp/*"))
      # require "#{Wagn.root}/config/environment"
      importer = Importer.new location
      puts "Source DB: #{importer.export_location}".green
      yield importer
      FileUtils.rm_rf(Dir.glob("tmp/*"))
    end

    def ensure_env env
      if !ENV["RAILS_ENV"] || ENV["RAILS_ENV"].to_sym != env.to_sym
        puts "restart task in #{env} environment"
        execute_command "rake #{ARGV.join(" ")}", env
      else
        yield
      end
    end

    desc "seed test database"
    task :seed do
      mysql_login = "mysql -u #{user}"
      mysql_login += " -p#{pwd}" if pwd
      cmd =
        "echo \"create database if not exists #{testdb}\" | #{mysql_login}; " \
        "#{mysql_login} --database=#{testdb} < #{db_path}"
      system cmd
    end

    desc "add wikirate test data to test database"
    task add_wikirate_test_data: :environment do
      ensure_env "test" do
        require "#{Wagn.root}/test/seed.rb"
        SharedData.add_wikirate_data
      end
    end

    desc "update seed data using the production database"
    task reseed_data: :environment do |_t, _args|
      unless testdb
        puts "no test database"
        exit
      end
      ensure_env :init_test do
        # start with raw wagn db
        Rake::Task["wagn:seed"].invoke

        location = ARGV.size > 1 ? ARGV.last : "production"
        Rake::Task["wikirate:test:import_from"].invoke(location)
        # dump just in case some goes wrong in the next steps
        # Then we don't have to import everything again
        Rake::Task["wikirate:test:dump_test_db"].invoke
        Rake::Task["wagn:migrate"].invoke
        Card::Cache.reset_all
        Rake::Task["wikirate:test:add_wikirate_test_data"].invoke
        Card::Cache.reset_all
        Rake::Task["wikirate:test:update_machine_output"].invoke
        Rake::Task["wikirate:test:dump_test_db"].invoke
        puts "Happy testing!"
      end
      exit # don't execute the location argument as second rake task
    end

    task :import_from, [:location] => :environment do |_t, args|
      ensure_env :init_test do
        location = args[:location] || "production"
        import_from(location) do |import|
          # cardtype has to be the first
          # otherwise codename cards get tbe wrong type
          import.cards_of_type "cardtype"
          import.items_of :codenames
          import.cards_of_type "year"

          Card.search(type_id: Card::SettingID, return: :name).each do |setting|
            # TODO: make export view for setting cards
            #   then we don't need to import all script and style cards
            #   we do it via subitems: true
            with_subitems = %w(*script *style *layout).include? setting
            import.items_of setting, subitems: with_subitems
          end
          import.items_of :production_export, subitems: true
          import.migration_records
        end
      end
    end

    task update_machine_output: :environment do
      ensure_env :test do
        Card[:all, :script].update_machine_output
        Card[:all, :style].update_machine_output
      end
    end

    desc "dump test database"
    task :dump_test_db do
      mysql_args = "-u #{user}"
      mysql_args += " -p #{pwd}" if pwd
      execute_command "mysqldump #{mysql_args} #{testdb} > #{db_path}"
    end
  end
end
