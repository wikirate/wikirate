require 'colorize'
require 'pry'
namespace :wikirate do
  namespace :test do
    db_path = File.join Wagn.root, 'test', 'wikiratetest.db'
    test_database =
      (t = Wagn.config.database_configuration['test']) && t['database']
    prod_database =
      (p = Wagn.config.database_configuration['production']) && p['database']
    user = ENV['MYSQL_USER'] || 'root'
    pwd  = ENV['MYSQL_PASSWORD']

    desc 'seed test database'
    task :seed do
      mysql_args = "-u #{user}"
      mysql_args += " -p #{pwd}" if pwd
      system "mysql #{mysql_args} #{test_database} < #{db_path}"
    end

    desc 'add wikirate test data to test database'
    task :add_wikirate_test_data do
      require "#{Wagn.root}/config/environment"
      require "#{Wagn.root}/test/seed.rb"
      SharedData.add_wikirate_data
    end

    def update_or_create name, codename, attr
      if attr['type'].in? ['Image', 'File']
        attr['content'] = ''
        attr['empty_ok'] = true
      end
      begin
        # card = codename ? Card.fetch(codename.to_sym) : Card.fetch(name)
        card = Card.fetch(name)
        if card
          puts "updating card #{name} "\
               "#{card.update_attributes!(attr)}".light_blue
        else
          puts "creating card #{name} #{Card.create!(attr)}".yellow
        end
      rescue => e
        puts "Error in #{name}\n#{e}".red
      end
    end

    def truncate_table table
      sql = "TRUNCATE  #{table}"
      ActiveRecord::Base.connection.execute(sql)
    end

    def insert_migration_records data
      data.each do |table, values|
        begin
          value_string = values.join("'),('")
          value_string = "('#{value_string}')"
          truncate_table table
          sql = "INSERT INTO #{table} (version) VALUES #{value_string}"
          ActiveRecord::Base.connection.execute(sql)
        rescue => e
          puts "Error in #{table},#{values} #{e}".red
        end
      end
    end

    def execute_command cmd
      puts cmd.green
      system cmd
    end

    def get_data location
      puts 'getting production export'.green
      # we can let semaphore make the latest test db on the fly
      export_location =
        case location
        when 'dev'
          'dev.wikirate.org'
        when 'local'
          '127.0.0.1:3000'
        else
          'wikirate.org'
        end
      url = "http://#{export_location}/production_export.json?export=true"
      export = open(url, read_timeout: 50000).read
      puts 'Done'.green
      JSON.parse(export)
    end

    def import_data cards
      puts 'importing data'.green
      Card::Auth.as_bot
      cards['card']['value'].each do |card|
        update_or_create card['name'], card['codename'], card
      end
      puts 'Done'.green
    end

    desc 'update seed data using the production database'
    task :reseed_data do |_t, _args|
      location = ARGV.size > 1 ? ARGV.last : 'production'
      puts "Source DB Env: #{location}".green
      if ENV['RAILS_ENV'] != 'init_test'
        puts 'start task in test environment'
        system 'env RAILS_ENV=init_test rake '\
               "wikirate:test:reseed_data #{location}"
      elsif !test_database
        puts 'Error: no test database defined in config/database.yml'
      elsif !prod_database
        puts 'Error: no production database defined in config/database.yml'
      else
        # seed from raw wagn db
        execute_command 'RAILS_ENV=test wagn seed'
        FileUtils.rm_rf(Dir.glob('tmp/*'))
        require "#{Wagn.root}/config/environment"
        cards = get_data location
#        binding.pry
        import_data cards
        insert_migration_records cards['migration_record']
        FileUtils.rm_rf(Dir.glob('tmp/*'))
        env = 'RAILS_ENV=test'
        execute_command "#{env} rake wikirate:test:add_wikirate_test_data"
        execute_command "#{env} rake wagn:migrate"
        execute_command "#{env} rake wikirate:test:dump_test_db"
        puts 'Please pray'
      end
      exit
    end

    desc 'dump test database'
    task :dump_test_db do
      mysql_args = "-u #{user}"
      mysql_args += " -p #{pwd}" if pwd
      execute_command "mysqldump #{mysql_args} #{test_database} > #{db_path}"
    end
  end

  desc 'fetch json from export card on dev site and generate migration'
  task import_from_dev: :environment do
    if !ENV['name']
      puts "pass a name for the migration 'name=...'"
    elsif ENV['name'].match /^(?:import)_(.*)(?:\.json)?/
      require 'card/migration'

      export = open('http://dev.wikirate.org/export.json')
      File.open(Card::Migration.data_path("#{$1}.json"), 'w') do |f|
        f.print export.read
      end
      system "bundle exec wagn generate card:migration #{ENV['name']}"
    else
      puts 'invalid format: name must match /import_(.*)/'
    end
  end

  desc 'fetch json from local export card and generate migration'
  task import_from_local: :environment do
    if !ENV['name']
      puts "pass a name for the migration 'name=...'"
    elsif ENV['name'].match /^(?:import)_(.*)(?:\.json)?/
      require 'card/migration'
      require 'generators/card'
      export_hash = Card['export'].format(format: :json).render_content
      File.open(Card::Migration.data_path("#{$1}.json"), 'w') do |f|
        f.print JSON.pretty_generate(export_hash)
      end
      system "bundle exec wagn generate card:migration #{ENV['name']}"
    else
      puts 'invalid format: name must match /import_(.*)/'
    end
  end

  desc 'test the performance for a list of pages'
  task benchmark: :environment do
    def wbench_results_to_html results
      list = ''
      results.browser.each do |key, value|
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

    # host = 'http://dev.wikirate.org'
    host = 'http://localhost:3000'

    test_pages = ENV['page'] ? [ENV['page']] : ['Home']
    # test_pages = ENV['name'] ? [ENV['name']] : ['Home']
    runs = ENV['run'] || 1
    test_pages.each do |page|
      puts page

      log_args = { performance_log: {
        output: :card, output_card: page,
        methods: [
          :execute, :rule, :fetch, :view
        ], details: true, min_time: 1 } }
      url = "#{host}/#{page}"
      open "#{url}?#{log_args.to_param}"
      benchmark = WBench::Benchmark.new(url) { '' }
      results   = benchmark.run(runs) # => WBench::Results
      card = Card.fetch "#{page}+#{Card[:performance_log].name}",
                        new: { type_id: Card::PointerID }
      card.add_csv_entry page, results, runs
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

  namespace :task do
    desc 'remove empty metric value cards'
    task remove_empty_metric_value_cards: :environment do
      # require File.dirname(__FILE__) + '/../config/environment'
      # Card::Auth.as_bot
      Card::Auth.current_id = Card::WagnBotID

      Card.search(type: 'Metric') do |metric|
        puts "~~~\n\nworking on METRIC: #{metric.name}"

        value_groups = Card.search(
          left_id: metric.id,
          right: { type: 'Company' },
          not: {
            right_plus: [
              { type: 'Year' },
              { type: 'Metric Value' }
            ]
          }
        )

        puts "deleting #{value_groups.size} empty value cards"
        value_groups.each do |group_card|
          begin
            group_card.descendants.each do |desc|
              desc.update_column :trash, true
            end
            group_card.update_column :trash, true
          rescue
            puts "FAILED TO DELETE: #{group_card.name}"
          end
        end
      end
      puts 'empty trash'
      Card.empty_trash
    end

    desc 'delete all cards that are marked as trash'
    task 'empty_trash' => :environment do
      Card.empty_trash
    end
  end
end
