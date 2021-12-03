namespace :wikirate do
  namespace :test do
    namespace :seed do
      desc "add updated seed data"
      task update: :environment do
        Rake::Task["decko:seed"].invoke
        Rake::Task["card:migrate:deck_structure"].invoke
        Cardio::Migration.assume_current # deck_cards

        execute_command "rake card:eat -- -v", :test
        execute_command "rake wikirate:test:seed:update_assets", :test
      end

      desc "add update_assets"
      task update_assets: :environment do |task|
        Cardio.config.delaying = false

        ensure_env :test, task do
          Rake::Task["card:mod:uninstall"].execute
          Rake::Task["card:mod:install"].execute
          Rake::Task["decko:seed:make_asset_output_coded"].execute
          Rake::Task["wikirate:test:dump"].execute
        end
      end
    end
  end
end
