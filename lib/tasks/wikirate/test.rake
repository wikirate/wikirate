require "colorize"
require File.expand_path "../importer", __FILE__

namespace :wikirate do
  namespace :test do
    full_dump_path = File.join Wagn.root, "test", "seed.db"
    base_dump_path = File.join Wagn.root, "test", "base_seed.db"
    user = ENV["DATABASE_MYSQL_USERNAME"] || ENV["MYSQL_USER"] || "root"
    pwd  = ENV["DATABASE_MYSQL_PASSWORD"] || ENV["MYSQL_PASSWORD"]

    def testdb
      @testdb ||= ENV["DATABASE_NAME_TEST"] ||
                  ((t = Wagn.config.database_configuration["test"]) &&
                  t["database"])
    end

    def execute_command cmd, env=nil
      cmd = "env RAILS_ENV=#{env} #{cmd}" if env
      puts cmd.green
      system cmd
    end

    def import_from location
      FileUtils.rm_rf(Dir.glob("tmp/*"))
      require "#{Wagn.root}/config/environment"
      importer = Importer.new location
      puts "Source DB: #{importer.export_location}".green
      yield importer
      FileUtils.rm_rf(Dir.glob("tmp/*"))
    end

    def ensure_env env, task, args=nil
      if !ENV["RAILS_ENV"] || ENV["RAILS_ENV"].to_sym != env.to_sym
        puts "restart task in #{env} environment"
        if args.to_a.present?
          task = "#{task}\\[#{args.to_a.join(',')}\\]"
        end
        execute_command "rake #{task}", env
      else
        yield
      end
    end

    def ensure_test_db
      return if testdb
      puts "no test database"
      exit
    end

    desc "seed test database"
    task seed: :load_test_dump

    desc "update seed data using the production database"
    task :reseed_data, [:location]  do |_task, args|
      ensure_test_db
      Rake::Task["wikirate:test:prepare_seed_data"].invoke(args[:location])
      Rake::Task["wikirate:test:finalize_seed_data"].invoke
    end

    desc "seed with raw wagn test db and import cards"
    task :prepare_seed_data, [:location]  do |task, args|
      # init_test env uses the same db as test env
      # test env triggers stuff on load that breaks the seeding process
      ensure_env :init_test, task, args do
        execute_command "rake wagn:seed", :test
        Rake::Task["wikirate:test:import_from"].invoke(args[:location])
        Rake::Task["wikirate:test:dump_test_db"].invoke(base_dump_path)
      end
    end

    desc "migrate and add wikirate test data"
    task :finalize_seed_data do |task|
      ensure_env :test, task do
        Rake::Task["wikirate:test:load_test_dump"].invoke(base_dump_path)
        Rake::Task["wagn:migrate"].invoke
        Card::Cache.reset_all
        Rake::Task["wikirate:test:add_wikirate_test_data"].invoke
        Card::Cache.reset_all
        Rake::Task["wikirate:test:update_machine_output"].invoke
        Rake::Task["wikirate:test:dump_test_db"].execute
      end
    end

    desc "import cards from given location"
    task :import_from, [:location] => :environment do |task, args|
      ensure_env(:init_test, task, args) do
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

    desc "add wikirate test data to test database"
    task add_wikirate_test_data: :environment do |task|
      ensure_env "test", task do
        require "#{Wagn.root}/test/seed.rb"
        SharedData.add_wikirate_data
      end
    end

    desc "update caches for machine output"
    task update_machine_output: :environment do |task|
      ensure_env :test, task do
        Card::Auth.as_bot do
          Card[:all, :script].update_machine_output
          Card[:all, :style].update_machine_output
          # because we don't copy the files we have to delete the output
          # but the solid caches for generating the machine output
          # are updated now
          Card[:all, :script, :machine_output].delete
          Card[:all, :style, :machine_output].delete
        end
      end
    end

    desc "dump test database"
    task :dump_test_db, [:path] do |_task, args|
      dump_path = args[:path] || full_dump_path
      mysql_args = "-u #{user}"
      mysql_args += " -p #{pwd}" if pwd
      execute_command "mysqldump #{mysql_args} #{testdb} > #{dump_path}"
    end

    desc "load db dump into test db"
    task :load_test_dump, [:path] do |_task, args|
      dump_path = args[:path] || full_dump_path
      mysql_login = "mysql -u #{user}"
      mysql_login += " -p#{pwd}" if pwd
      cmd =
        "echo \"create database if not exists #{testdb}\" | #{mysql_login}; " \
        "#{mysql_login} --database=#{testdb} < #{dump_path}"
      system cmd
    end
  end
end
