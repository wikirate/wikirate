namespace :wikirate do
  namespace :test do
    namespace :seed do
      base_dump_path = File.join Wagn.root, "test", "base_seed.db"
      migrated_dump_path = File.join Wagn.root, "test", "migrated_seed.db"

      desc "update seed data using the production database"
      task :generate, [:location] do |_task, args|
        ensure_test_db
        Rake::Task["wikirate:test:seed:generate_base"].invoke(args[:location])
        Rake::Task["wikirate:test:seed:migrate"].invoke
      end

      desc "seed with raw wagn test db and import cards"
      task :generate_base, [:location] do |task, args|
        # init_test env uses the same db as test env
        # test env triggers stuff on load that breaks the seeding process
        ensure_env :init_test, task, args do
          execute_command "rake wagn:seed", :test
          Rake::Task["wikirate:test:import_from"].invoke(args[:location])
          Rake::Task["wikirate:test:seed:dump"].invoke(base_dump_path)
        end
      end

      desc "migrate test data"
      task :migrate do |task|
        ensure_env :test, task do
          Rake::Task["wikirate:test:load_test_dump"].invoke(base_dump_path)
          Rake::Task["wagn:migrate"].invoke
          Rake::Task["wikirate:test:dump_test_db"].invoke(migrated_dump_path)
          Card::Cache.reset_all
          Rake::Task["wikirate:test:seed:update"].invoke
        end
      end

      desc "add updated seed data"
      task :update do |task|
        ensure_env :test, task do
          Rake::Task["wikirate:test:load_test_dump"].invoke(migrated_dump_path)
          Rake::Task["wikirate:test:seed:add_wikirate_test_data"].invoke
          Card::Cache.reset_all
          Rake::Task["wikirate:test:update_machine_output"].invoke
          Rake::Task["wikirate:test:seed:dump"].execute
        end
      end

      desc "add wikirate test data to test database"
      task add_wikirate_test_data: :environment do |task|
        ensure_env "test", task do
          require "#{Wagn.root}/test/seed.rb"
          SharedData.add_wikirate_data
        end
      end

    end
  end
end
