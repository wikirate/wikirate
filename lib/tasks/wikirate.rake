require 'colorize'

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
    task :reseed_data do
      if ENV['RAILS_ENV'] != 'init_test'
        puts "start task in test environment"
        system 'env RAILS_ENV=init_test rake wikirate:test:reseed_data'
      elsif !test_database
        puts "Error: no test database defined in config/database.yml"
      elsif !prod_database
        puts "Error: no production database defined in config/database.yml"
      else
        # seed from raw wagn db
        seed_test_db = "RAILS_ENV=test wagn seed"
        puts seed_test_db.green
        system seed_test_db


        require "#{Wagn.root}/config/environment"
        
        puts "getting production export".green
        export = open("http://127.0.0.1:3000/production_export.json").read
        puts "Done".green
        cards = JSON.parse(export)
        Card::A
        cards["card"]["value"].each do |c|
          unless Card.exists?(c["name"])
            puts "creating card #{c}"
            Card.create! c 
          end
        end
        require "#{Wagn.root}/test/seed.rb"
        SharedData.add_wikirate_data
      end
      exit()
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

        # select 5 companies and topics and metrics
        companies = [Card["Apple Inc."],Card["Amazon.com, Inc."],Card["Samsung"],Card["Siemens AG"],Card["Sony Corporation"]]
        topics = [Card["Natural Resource Use"],Card["Community"],Card["Human Rights"],Card["Climate Change"],Card["Animal Welfare"]]
        metrics = [Card['Sebastian Jekutsch+CSR Report Available'],Card['Good Company Index+Good Company Grade'],Card['BSR+BSR Member']]
        company_ids = ""
        topic_ids = ""
        metric_ids = ""
        company_names = Array.new
        topic_names = Array.new

        card_to_be_kept = Array.new

        companies.each do |company|
          company_ids += "#{company.id},"
          company_names.push company.name
        end

        topics.each do |topic|
          topic_ids += "#{topic.id},"
          topic_names.push topic.name
        end


        # metrics.each do |metric|
        #   metric_ids += "#{metric.id},"
        #   card_to_be_kept << metric.id
        #   card_to_be_kept += Card.search :left=>metric.name, :return=>:id
        # end



        company_related_article = Card.search :type=>"Analysis",:left=>{:name=> company_names.unshift("in")}
        topic_related_article = Card.search :type=>"Analysis",:right=>{:name=>topic_names.unshift("in")}

        (companies + topics ).each do |c|
          search_args = {:type=>["in","claim","source"]}
          query = Card.tag_filter_query(c.name, search_args,['company','topic'])
          cards = Card.search query
          cards.each do |card|
            card_to_be_kept.push card.id
          end
        end


        (company_related_article + topic_related_article).each do |c|
          card_to_be_kept.push c.id
        end
        alias_card_id = Card["aliases"].id

        card_id_to_be_kept = card_to_be_kept.push(alias_card_id).compact.join(",")

        type_ids = %w{ Claim Company Market Issue Topic Analysis Task Newspaper Book Activists Donor Website Person Institution Donor Status Organization Periodical Source Metric_value }.map do |typename|
          id = Card.fetch_id(typename)
          "'#{id}'" if id
        end.compact
        type_ids_str = type_ids.join(",")

        type_ids.delete("'#{Card::WikirateCompanyID}'")
        type_ids.delete("'#{Card::WikirateTopicID}'")
        #type_ids.delete("'#{Card::MetricID}'")
        type_ids_without_company_and_topic = type_ids.join(",")

        vote_ids = %w{ *upvotes *downvotes }.map do |vote_name|
          "'#{Card.fetch_id(vote_name)}'"
        end.join ','

        ActiveRecord::Base.connection.execute 'delete from card_revisions'
        #ActiveRecord::Base.connection.execute 'delete from card_actions'
        #xActiveRecord::Base.connection.execute 'delete from card_changes'

        # delete claims, pages and websites
#        ActiveRecord::Base.connection.execute 'delete from cards where type_id = 631 or type_id = 2327 or type_id = 4030'
        ActiveRecord::Base.connection.execute 'drop table card_revisions'
        ActiveRecord::Base.connection.execute 'drop table users'
        ActiveRecord::Base.connection.execute 'delete from sessions'
        # delete companies
        ActiveRecord::Base.connection.execute "delete from cards where type_id = '#{Card::WikirateCompanyID}' and id not in ( #{company_ids[0...-1]} )"
        # delete topics
        ActiveRecord::Base.connection.execute "delete from cards where type_id = '#{Card::WikirateTopicID}' and id not in ( #{topic_ids[0...-1]} )"
        #ActiveRecord::Base.connection.execute "delete from cards where type_id = '#{Card::MetricID}'" # and id not in ( #{metric_ids[0...-1]} )"

        # delete all webpage++link
        # 47294 is alias card
        ActiveRecord::Base.connection.execute "delete ca from cards ca inner join cards le ON ca.left_id = le.id where le.type_id in (#{type_ids_str}) and ca.id not in  ( #{card_id_to_be_kept} ) and ca.right_id <> '#{alias_card_id}'"
        ActiveRecord::Base.connection.execute "delete from cards where type_id in (#{type_ids_without_company_and_topic}) and id not in ( #{card_id_to_be_kept} )"
        ActiveRecord::Base.connection.execute "delete from cards where right_id in (#{vote_ids})"

        puts "clean database"
        Rake::Task['wagn:bootstrap:clean'].invoke
        puts "add test data"
        require "#{Wagn.root}/test/seed.rb"
        SharedData.add_test_data
        puts "mysqldump #{mysql_args} #{test_database} > #{db_path}"
        system "mysqldump #{mysql_args} #{test_database} > #{db_path}"
        # prevent from looping
        exit
      end
    end
  end

# delete from cards where type_id = 631;
# delete from cards where type_id = 2327;
# delete from card_references;

  desc "fetch json from export card on dev site and generate migration"
  task :import_from_dev => :environment do

    if !ENV['name']
      puts "pass a name for the migration 'name=...'"
    elsif ENV['name'].match /^(?:import)_(.*)(?:\.json)?/
      require 'card/migration'

      export = open("http://dev.wikirate.org/export.json")
      File.open(Card::Migration.data_path("#{$1}.json"),'w') do |f|
        f.print export.read
      end
      system "bundle exec wagn generate card:migration #{ENV['name']}"
    else
      puts "invalid format: name must match /import_(.*)/"
    end
  end


  desc "fetch json from local export card and generate migration"
  task :import_from_local => :environment do

    if !ENV['name']
      puts "pass a name for the migration 'name=...'"
    elsif ENV['name'].match /^(?:import)_(.*)(?:\.json)?/
      require 'card/migration'
      require 'generators/card'
      export_hash = Card['export'].format(:format=>:json).render_content
      File.open(Card::Migration.data_path("#{$1}.json"),'w') do |f|
        f.print JSON.pretty_generate(export_hash)
      end
      system "bundle exec wagn generate card:migration #{ENV['name']}"
    else
      puts "invalid format: name must match /import_(.*)/"
    end
  end

  desc "test the performance for a list of pages"
  task :benchmark => :environment do

    def wbench_results_to_html results
      list = ''
      results.browser.each do |key,value|
        list += %{
                <li class="list-group-item">
                  <span class="badge">#{value}</span>
                  #{key}
                </li>
              }
      end
      %{
        <ul class="list-group">
          #{list}
        </ul>
      }
    end

    #host = 'http://dev.wikirate.org'
    host = 'http://localhost:3000'
    test_pages = ENV['page'] ? [ENV['page']] : ['Companies'] #['Home','Articles','Topics','Companies','Metrics','Claims','Sources','Sara_Cifani','Apple_Inc','Natural_Resource_Use','McDonald_s_Corporation+Natural_Resource_Use', 'Newsweek+Newsweek_Green_Score']
    #test_pages = ENV['name'] ? [ENV['name']] : ['Home']
    runs = ENV['run'] || 1
    log_args = {:performance_log=>{:output=>:card, :methods=>[:view, :search, :fetch], :details=>true, :min_time=>1}}
    test_pages.each do |page|
      url = "#{host}/#{page}"
      puts page
      open "#{url}?#{log_args.to_param}"
      benchmark = WBench::Benchmark.new(url) { '' }
      results   = benchmark.run(runs) # => WBench::Results
      Card[:performance_log].add_csv_entry page, results, runs
    end

    # results.app_server # =>
    #   [25, 24, 24]
    #
    # results.browser # =>
    #   {
    #     "navigationStart"            => [0, 0, 0],
    #     "fetchStart"                 => [0, 0, 0],
    #     "domainLookupStart"          => [0, 0, 0],
    #     "domainLookupEnd"            => [0, 0, 0],
    #     "connectStart"               => [12, 12, 11],
    #     "connectEnd"                 => [609, 612, 599],
    #     "secureConnectionStart"      => [197, 195, 194],
    #     "requestStart"               => [609, 612, 599],
    #     "responseStart"              => [829, 858, 821],
    #     "responseEnd"                => [1025, 1053, 1013],
    #     "domLoading"                 => [1028, 1055, 1016],
    #     "domInteractive"             => [1549, 1183, 1136],
    #     "domContentLoadedEventStart" => [1549, 1183, 1136],
    #     "domContentLoadedEventEnd"   => [1549, 1184, 1137],
    #     "domComplete"                => [2042, 1712, 1663],
    #     "loadEventStart"             => [2042, 1712, 1663],
    #     "loadEventEnd"               => [2057, 1730, 1680]
    #   }
  end
end


