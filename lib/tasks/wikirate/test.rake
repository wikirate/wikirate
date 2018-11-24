require "colorize"
require File.expand_path "../importer", __FILE__

namespace :wikirate do
  namespace :test do
    full_dump_path = File.join Decko.root, "test", "seed.db"

    def testdb
      @testdb ||= ENV["DATABASE_NAME_TEST"] ||
                  ((t = Decko.config.database_configuration["test"]) &&
                  t["database"])
    end

    def execute_command cmd, env=nil
      cmd = "env RAILS_ENV=#{env} #{cmd}" if env
      puts cmd.green
      system cmd
    end

    def import_from location
      FileUtils.rm_rf(Dir.glob("tmp/*"))
      require "#{Decko.root}/config/environment"
      importer = Importer.new location
      puts "Source DB: #{importer.export_location}".green
      yield importer
      FileUtils.rm_rf(Dir.glob("tmp/*"))
    end

    def ensure_env env, task, args=nil
      if !ENV["RAILS_ENV"] || ENV["RAILS_ENV"].to_sym != env.to_sym
        puts "restart task in #{env} environment"
        task = "#{task}\\[#{args.to_a.join(',')}\\]" if args.to_a.present?
        execute_command "rake #{task}", env
      elsif block_given?
        yield
      end
    end

    def with_env_var key, value
      old_val = ENV[key]
      ENV[key] = value
      result = yield
      old_val ? ENV[key] = old_val : ENV.delete(key)
      result
    end

    def ensure_test_db
      return if testdb
      puts "no test database"
      exit
    end

    desc "seed test database"
    task seed: :load_dump

    desc "import cards from given location"
    task :import_from, [:location] => :environment do |task, args|
      ensure_env(:init_test, task, args) do
        Card::Cache.reset_all
        import_wikirate_essentials(args[:location] || "live")
      end
    end

    desc "update caches for machine output"
    task update_machine_output: :environment do |task|
      ensure_env :test, task do
        Card::Auth.as_bot do
          [[:all, :script],
           [:all, :style],
           [:script_html5shiv_printshiv]].each do |name_parts|
            Card[*name_parts, :machine_output]&.delete
            Card[*name_parts].update_machine_output
            codename = "#{name_parts.join('_')}_output"
            Card[*name_parts, :machine_output].update_attributes!(
              codename: codename, storage_type: :coded, mod: :test
            )
          end
        end
      end
    end

    desc "load db dump into test db"
    task :load_dump, [:path] do |_task, args|
      dump_path = args[:path] || ARGV[1] || full_dump_path
      load_dump dump_path, testdb
    end


    desc "dump test database"
    task :dump, [:path] do |_task, args|
      dump_path = args[:path] || full_dump_path
      dump dump_path, testdb
    end
  end
end
