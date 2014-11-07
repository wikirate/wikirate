namespace :wikirate do
  desc "update test database"
  task :update_test_db => :environment do
      ENV['RAILS_ENV'] = 'test'
      require "#{Wagn.root}/config/environment"
      Wagn.config.action_mailer.delivery_method = :test
      Wagn.config.action_mailer.perform_deliveries = false
      puts 'Import wikirate database'
      test_database = Wagn.config.database_configuration["test"]["database"]
      system "mysql -u root #{test_database} < /tmp/wikirate/db"
      Rake::Task['wagn:migrate'].invoke
      puts "Seed test data"
      require "#{Wagn.root}/test/seed.rb"
      SharedData.add_test_data
      puts "Clean data"
      Rake::Task['wagn:bootstrap:clean'].invoke
      puts "Dump data to  #{Wagn.root}/test/wikiratetest.db"
      system "mysqldump -u root wikirate > #{Wagn.root}/test/wikiratetest.db"
  end

  desc "fetch json from export card and generate migration"
  task :import_from_dev do
    if !ENV['name']
      puts "pass a name for the migration 'name=...'"
    elsif ENV['name'].match /^(?:import)_(.*)(?:\.json)?/ 
      require "#{Wagn.root}/config/environment"
      export = open("http://dev.wikirate.org/export.json")
      File.open(File.join(Wagn::Migration.deck_card_migration_paths.first, 'data', "#{$1}.json"),'w') do |f|
        f.print export.read
      end
      system "bundle exec wagn generate card_migration #{ENV['name']}"
    else
      puts "invalid format: name must match /import_(.*)/"
    end
  end
end
