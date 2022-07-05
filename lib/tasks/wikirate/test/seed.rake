# namespace :wikirate do
#   namespace :test do
#     namespace :seed do
#       desc "add updated seed data"
#       task update: :environment do
#         Rake::Task["decko:seed"].invoke
#         ENV["NO_CARD_LOAD"] = "true"
#         Rake::Task["card:migrate:deck_structure"].invoke
#         Cardio::Migration.assume_current # deck_cards
#
#         execute_command "rake card:eat -- -v", :test
#         execute_command "rake wikirate:test:seed:update_assets", :test
#       end
#
#       desc "add update_assets"
#       task update_assets: :environment do |task|
#         Cardio.config.delaying = false
#
#         ensure_env :test, task do
#           Rake::Task["card:mod:uninstall"].execute
#           Rake::Task["card:mod:install"].execute
#           ENV["STYLE_OUTPUT_MOD"] = "wikirate"
#           Rake::Task["decko:assets:code"].execute
#           Rake::Task["wikirate:test:dump"].execute
#         end
#       end
#     end
#   end
# end
