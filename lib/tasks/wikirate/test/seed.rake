namespace :wikirate do
  namespace :test do
    namespace :seed do
      base_dump_path = File.join Decko.root, "test", "base_seed.db"
      migrated_dump_path = File.join Decko.root, "test", "migrated_seed.db"

      # run it with rake "wikirate:test:seed:generate[local]" to fetch data from local server
      desc "update seed data using the production database"
      task :generate, [:location] do |_task, args|
        ensure_test_db
        Rake::Task["wikirate:test:seed:generate_base"].invoke(args[:location])
        Rake::Task["wikirate:test:seed:migrate"].invoke
      end

      desc "seed with raw decko test db and import cards"
      task :generate_base, [:location] do |task, args|
        # init_test env uses the same db as test env
        # test env triggers stuff on load that breaks the seeding process
        ensure_env :init_test, task, args do
          # with_env_var "CARD_MODS", "none" do
          execute_command "rake decko:seed_without_reset", :test
          Rake::Task["wikirate:test:import_from"].invoke(args[:location])
          Delayed::Job.delete_all
          Rake::Task["wikirate:test:dump"].invoke(base_dump_path)
          # end
        end
      end

      desc "migrate test data starting from base"
      task :remigrate do |task|
        ensure_env :test, task do
          Rake::Task["wikirate:test:load_dump"].invoke(base_dump_path)
          Rake::Task["decko:migrate"].invoke
          Rake::Task["wikirate:test:dump"].invoke(migrated_dump_path)
          Card::Cache.reset_all
          ActiveRecord::Base.descendants.each(&:reset_column_information)
        end
        ensure_env :test, "wikirate:test:seed:update"
      end

      desc "migrate test data starting from last migration run"
      task :migrate do |task|
        ensure_env :test, task do
          Rake::Task["wikirate:test:load_dump"].invoke(migrated_dump_path)
          Rake::Task["decko:migrate"].invoke
          Rake::Task["wikirate:test:dump"].invoke(migrated_dump_path)
          Card::Cache.reset_all
          ActiveRecord::Base.descendants.each(&:reset_column_information)
        end
        ensure_env :test, "wikirate:test:seed:update"
      end

      desc "add updated seed data"
      task update: :environment do |task|
        ensure_env :test, task do
          Rake::Task["wikirate:test:load_dump"].invoke(migrated_dump_path)
          Card # I don't fully understand why this is necessary, but without it there
          # is an autoloading problem.

          Rake::Task["wikirate:test:seed:add_wikirate_test_data"].invoke
          Card::Cache.reset_all
          Rake::Task["wikirate:test:update_machine_output"].invoke
          Rake::Task["wikirate:test:dump"].execute
        end
      end

      desc "add wikirate test data to test database"
      task add_wikirate_test_data: :environment do |task|
        ensure_env :test, task do
          require "#{Decko.root}/test/shared_data.rb"
          SharedData.add_wikirate_data
        end
      end
    end
  end
end
