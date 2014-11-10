namespace :wikirate do
  namespace :test do
    
    db_path = File.join Wagn.root, 'test', 'wikiratetest.db'
    test_database = Wagn.config.database_configuration["test"]["database"]
    prod_database = Wagn.config.database_configuration["production"]["database"]        
    user = ENV['MYSQL_USER'] || 'root'
    pwd  = ENV['MYSQL_PASSWORD'] 
    
    
    desc "seed test database"
    task :seed do
      mysql_args = "-u #{user}"
      mysql_args += " -p #{pwd}" if pwd
      system "mysql #{mysql_args} #{test_database} < #{db_path}"
    end
    
    desc 'update seed data using the production database'
    task :update_seed_data do 
      if ENV['RAILS_ENV'] != 'test'
        system 'env RAILS_ENV=test rake wikirate:test:update_seed_data'
      else
        tmp_path = File.join Wagn.paths['tmp'].first, 'test.db'
        require "#{Wagn.root}/config/environment"
        Wagn.config.action_mailer.delivery_method = :test
        Wagn.config.action_mailer.perform_deliveries = false
        puts 'copy production database to test database'
        mysql_args = "-u #{user}"
        mysql_args += " -p #{pwd}" if pwd
        system "mysqldump #{mysql_args} #{prod_database} > #{db_path}"
        system "mysql #{mysql_args} #{test_database} < #{db_path}"
        Rake::Task['wagn:migrate'].invoke
        puts "clean database"
        Rake::Task['wagn:bootstrap:clean'].invoke
        puts "add test data"
        require "#{Wagn.root}/test/seed.rb"
        SharedData.add_test_data
        system "mysqldump #{mysql_args} #{test_database} > #{db_path}"
      end
    end
  end
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
