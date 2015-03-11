namespace :wikirate do
  namespace :test do

    db_path = File.join Wagn.root, 'test', 'wikiratetest.db'
    test_database = (t = Wagn.config.database_configuration["test"] and t["database"])
    prod_database = (p = Wagn.config.database_configuration["production"] and p["database"])
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
        puts "start task in test environment"
        system 'env RAILS_ENV=test rake wikirate:test:update_seed_data'
      elsif !test_database
        puts "Error: no test database defined in config/database.yml"
      elsif !prod_database
        puts "Error: no production database defined in config/database.yml"
      else
        tmp_path = File.join Wagn.paths['tmp'].first, 'test.db'
        puts 'copy production database to test database'
        mysql_args = "-u #{user}"
        mysql_args += " -p #{pwd}" if pwd
        system "mysqldump #{mysql_args} #{prod_database} > #{db_path}"
        system "mysql #{mysql_args} #{test_database} < #{db_path}"
        
        require "#{Wagn.root}/config/environment"
        Wagn.config.action_mailer.delivery_method = :test
        Wagn.config.action_mailer.perform_deliveries = false
        if (card = Card.fetch 'A')  # there is a user 'A' on wikirate that conflicts with the test data
          card.destroy
        end
        Rake::Task['wagn:migrate'].invoke
        # binding.pry
        companies = [Card["Apple"],Card["Amazon"],Card["Samsung"],Card["Siemens"],Card["Sony Corporation"]]
        topics = [Card["Natural Resource Use"],Card["Community"],Card["Human Rights"],Card["Climate Change"],Card["Animal Welfare"]]

        company_ids = ""
        topic_ids = ""

        company_names = ""
        topic_names = ""

        companies.each do |company|
          company_ids += "#{company.id},"
          company_names+=",#{company.name}"
        end

        topics.each do |topic|
          topic_ids += "#{topic.id},"
          topic_names+=",#{topic.name}"
        end



        card_to_be_kept = ""


        company_related_article = Card.search :type=>"Analysis",:left=>["in#{company_names}"]
        topic_related_article = Card.search :type=>"Analysis",:right=>["in#{topic_names}"]

        (companies + topics ).each do |c|
          search_args = {:type=>["in","claim","page"]}
          query = Card.tag_filter_query(c.name, search_args,['company','topic'])
          cards = Card.search query
          cards.each do |card|
            card_to_be_kept+= "#{card.id},"
          end
        end

        (company_related_article + topic_related_article).each do |c|
          card_to_be_kept+= "#{c.id},"
        end

        ActiveRecord::Base.connection.execute 'delete from card_revisions'
        #ActiveRecord::Base.connection.execute 'delete from card_actions'
        #xActiveRecord::Base.connection.execute 'delete from card_changes'
        
        # delete claims, pages and websites
#        ActiveRecord::Base.connection.execute 'delete from cards where type_id = 631 or type_id = 2327 or type_id = 4030'
        ActiveRecord::Base.connection.execute 'drop table card_revisions'
        ActiveRecord::Base.connection.execute 'drop table users'
        ActiveRecord::Base.connection.execute 'delete from sessions'
        binding.pry
        # delete companies
        ActiveRecord::Base.connection.execute "delete from cards where type_id = '651' and id not in ( #{company_ids[0...-1]} )"
        # delete topics
        ActiveRecord::Base.connection.execute "delete from cards where type_id = '1010' and id not in ( #{topic_ids[0...-1]} )"

        # delete all webpage++link
        ActiveRecord::Base.connection.execute "delete ca from cards ca inner join cards le ON ca.left_id = le.id where le.type_id in ('631' '651' '699' '974' '1010' '1109' '1591' '1638' '1690' '2207' '2317' '2327' '2754' '2755' '2813' '2995' '4010' '4030') and ca.id not in  ( #{card_to_be_kept[0...-1]} )" 
        ActiveRecord::Base.connection.execute "delete from cards where type_id in ('631' '699' '974' '1109' '1591' '1638' '1690' '2207' '2317' '2327' '2754' '2755' '2813' '2995' '4010' '4030') and id not in ( #{card_to_be_kept[0...-1]} )"
        puts "clean database"
        Rake::Task['wagn:bootstrap:clean'].invoke
        puts "add test data"
        require "#{Wagn.root}/test/seed.rb"
        SharedData.add_test_data
        puts "mysqldump #{mysql_args} #{test_database} > #{db_path}"
        system "mysqldump #{mysql_args} #{test_database} > #{db_path}"
        exit
      end
    end
  end
  
#  delete from cards where type_id = 631;
#delete from cards where type_id = 2327;
#delete from card_references;

  desc "fetch json from export card on dev site and generate migration"
  task :import_from_dev do
    
    if !ENV['name']
      puts "pass a name for the migration 'name=...'"
    elsif ENV['name'].match /^(?:import)_(.*)(?:\.json)?/
      require "#{Wagn.root}/config/environment"
      require 'card/migration'
      
      export = open("http://dev.wikirate.org/export.json")
      File.open(Card::Migration.data_path("#{$1}.json"),'w') do |f|
        f.print export.read
      end
      system "bundle exec wagn generate card_migration #{ENV['name']}"
    else
      puts "invalid format: name must match /import_(.*)/"
    end
  end


  desc "fetch json from local export card and generate migration"
  task :import_from_local do
    
    if !ENV['name']
      puts "pass a name for the migration 'name=...'"
    elsif ENV['name'].match /^(?:import)_(.*)(?:\.json)?/
      require "#{Wagn.root}/config/environment"
      require 'card/migration'
      export_hash = Card['export'].format(:format=>:json).render_content
      File.open(Card::Migration.data_path("#{$1}.json"),'w') do |f|
        f.print JSON.pretty_generate(export_hash)
      end
      system "bundle exec wagn generate card_migration #{ENV['name']}"
    else
      puts "invalid format: name must match /import_(.*)/"
    end
  end
end
