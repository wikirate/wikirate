require 'colorize'

# require 'pry'
namespace :wikirate do
  namespace :test do
    db_path = File.join Wagn.root, 'test', 'seed.db'
    testdb = ENV['DATABASE_NAME_TEST'] ||
                    ((t = Wagn.config.database_configuration['test']) &&
                    t['database'])
    user = ENV['DATABASE_MYSQL_USERNAME'] || ENV['MYSQL_USER'] || 'root'
    pwd  = ENV['DATABASE_MYSQL_PASSWORD'] || ENV['MYSQL_PASSWORD']

    def execute_command cmd, env=nil
      cmd = "RAILS_ENV=#{env} #{cmd}" if env
      puts cmd.green
      system cmd
    end

    def import_from location
      FileUtils.rm_rf(Dir.glob('tmp/*'))
      require "#{Wagn.root}/config/environment"
      importer = Importer.new location
      puts "Source DB: #{importer.export_location}".green
      yield importer
      FileUtils.rm_rf(Dir.glob('tmp/*'))
    end

    desc 'seed test database'
    task :seed do
      mysql_login = "mysql -u #{user}"
      mysql_login += " -p#{pwd}" if pwd
      cmd =
        "echo \"create database if not exists #{testdb}\" | #{mysql_login}; " \
        "#{mysql_login} --database=#{testdb} < #{db_path}"
      system cmd
    end

    desc 'add wikirate test data to test database'
    task add_wikirate_test_data: :environment do
      if ENV['RAILS_ENV'] != 'test'
        execute_command 'rake wikirate:test:add_wikirate_test_data', :test
      else
        require "#{Wagn.root}/test/seed.rb"
        SharedData.add_wikirate_data
      end
    end

    desc 'update seed data using the production database'
    task :reseed_data do |_t, _args|
      location = ARGV.size > 1 ? ARGV.last : 'production'
      if ENV['RAILS_ENV'] != 'init_test'
        puts 'start task in init_test environment'
        system 'env RAILS_ENV=init_test rake '\
               "wikirate:test:reseed_data #{location}"
      elsif !testdb
        puts 'no test database'
      else
        # start with raw wagn db
        execute_command 'wagn seed', :test

        import_from(location) do |import|
          # cardtype has to be the first
          # otherwise codename cards get tbe wrong type
          import.cards_of_type 'cardtype'
          import.items_of :codenames
          import.cards_of_type 'year'
          # import.cards_of_type 'layout'
          # import.cards_of_type 'scss'
          # import.cards_of_type 'css'
          # import.cards_of_type 'coffee_script'
          # import.cards_of_type 'java_script'

          Card.search(type_id: Card::SettingID, return: :name).each do |setting|
            # TODO: make export view for setting cards
            #   then we don't need to import all script and style cards
            #   we do it via subitems: true
            with_subitems = %w(*script *style *layout).include? setting
            import.items_of setting, subitems: with_subitems
          end
          import.items_of :production_export, subitems: true
          import.migration_records
        end
        execute_command 'rake wagn:migrate', :test
        execute_command 'rake wikirate:test:add_wikirate_test_data', :test
        execute_command 'rake wikirate:test:dump_test_db', :test
        puts 'Happy testing!'
      end
      exit
    end

    desc 'dump test database'
    task :dump_test_db do
      mysql_args = "-u #{user}"
      mysql_args += " -p #{pwd}" if pwd
      execute_command "mysqldump #{mysql_args} #{testdb} > #{db_path}"
    end
  end
end

class Importer
  attr_reader :export_location
  def initialize location
    @export_location =
      case location
      when 'dev'    then 'dev.wikirate.org'
      when 'demo'   then 'demo.wikirate.org'
      when 'local'  then 'localhost:3000'
      else               'wikirate.org'
      end
  end

  # @return [Array<Hash>] each hash contains the attributes for a card
  def items_of cardname, opts={}
    card_data =
      work_on "getting data from #{cardname} card" do
        if opts[:subitems]
          json_export cardname, :export_items
        else
          json_export(cardname)['card']['value']
        end
      end
    import_card_data card_data
  end

  def cards_of_type type
    items_of "#{type}+*type+by_update"
  end

  def migration_records
    migration_data =
      work_on 'getting migration records' do
        json_export :admin_info, :migrations
      end
    work_on 'importing migration records' do
      import_migration_data migration_data
    end
  end

  private

  def work_on msg
    puts msg.green
    result = yield
    puts ' ... done'.green
    result
  end

  def json_export cardname, view=nil
    name = cardname.is_a?(Symbol) ? ":#{cardname}" : cardname.to_name.key
    url = "http://#{@export_location}/#{name}.json"
    url += "?view=#{view}" if view
    JSON.parse open(url, read_timeout: 50_000).read
  end

  def update_or_create name, _codename, attr
    if attr['type'].in? %w(Image File)
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

  def import_card_data cards
    work_on "importing data (#{cards.size} cards)" do
      Card::Auth.as_bot do
        cards.each do |card|
          update_or_create card['name'], card['codename'], card
        end
      end
    end
  end

  def import_migration_data data
    data.each do |table, values|
      begin
        truncate table
        insert_into table, values
      rescue => e
        puts "Error in #{table},#{values} #{e}".red
      end
    end
  end

  def truncate table
    sql = "TRUNCATE  #{table}"
    ActiveRecord::Base.connection.execute(sql)
  end

  def insert_into table, values
    value_string = values.join("'),('")
    value_string = "('#{value_string}')"
    sql = "INSERT INTO #{table} (version) VALUES #{value_string}"
    ActiveRecord::Base.connection.execute(sql)
  end
end

