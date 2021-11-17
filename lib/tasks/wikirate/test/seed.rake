namespace :wikirate do
  namespace :test do
    namespace :seed do
      base_dump_path = File.join Decko.root, "test", "dump", "base_seed.db"

      migrated_dump_path = File.join Decko.root, "test", "dump", "migrated_seed.db"

      # run it with rake "wikirate:test:seed:generate[local]" to fetch data from
      # local server
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
        Cardio.config.delaying = false

        ensure_env :test, task do
          Rake::Task["wikirate:test:load_dump"].invoke(migrated_dump_path)
          Cardio::Mod::Eat.new(verbose: true).up
          Card # I don't fully understand why this is necessary, but without it there
          # is an autoloading problem.
          Rake::Task["wikirate:test:seed:update_assets"].invoke
        end
      end

      desc "add update_assets"
      task update_assets: :environment do |task|
        Cardio.config.delaying = false

        ensure_env :test, task do
          Rake::Task["card:mod:uninstall"].execute
          Rake::Task["card:mod:install"].execute
          ENV["SEED_MACHINE_OUTPUT_TO"] = "test"
          Rake::Task["card:asset:refresh!"].execute
          Rake::Task["wikirate:test:dump"].execute
        end
      end
    end
  end
end
