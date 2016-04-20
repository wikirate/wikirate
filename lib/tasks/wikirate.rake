require 'colorize'
# require 'pry'
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
      export = open(url, read_timeout: 50_000).read
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
        import_data cards
        insert_migration_records cards['migration_record']
        FileUtils.rm_rf(Dir.glob('tmp/*'))
        env = 'RAILS_ENV=test'
        execute_command "#{env} rake wagn:migrate"
        execute_command "#{env} rake wikirate:test:add_wikirate_test_data"
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
    elsif ENV['name'] =~ /^(?:import)_(.*)(?:\.json)?/
      require 'card/migration'

      export = open('http://dev.wikirate.org/export.json')
      path = Card::Migration.data_path("#{Regexp.last_match(1)}.json")
      File.open(path, 'w') do |f|
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
    elsif ENV['name'] =~ /^(?:import)_(.*)(?:\.json)?/
      require 'card/migration'
      require 'generators/card'
      export_hash = Card['export'].format(format: :json).render_content
      path = Card::Migration.data_path("#{Regexp.last_match(1)}.json")
      File.open(path, 'w') do |f|
        f.print JSON.pretty_generate(export_hash)
      end
      system "bundle exec wagn generate card:migration #{ENV['name']}"
    else
      puts 'invalid format: name must match /import_(.*)/'
    end
  end

  desc 'create folders and files for scripts or styles'
  task add_codefile: :environment do
    with_params(:mod, :name, :type) do |mod, name, type|
      create_content_file mod, name, type
      create_rb_file mod, name
      create_migration_file name, type
    end
  end

  desc 'create folders and files for stylesheet'
  task add_stylesheet: :environment do
    ENV['type'] ||= 'scss'
    Rake::Task['wikirate:add_codefile'].invoke
  end

  desc 'create folders and files for script'
  task add_script: :environment do
    ENV['type'] ||= 'CoffeeScript'
    Rake::Task['wikirate:add_codefile'].invoke
  end

  desc 'test the performance for a list of pages'
  task benchmark: :environment do
    def wbench_results_to_html results
      list = ''
      results.browser.each do |key, value|
        list += %(
                <li class="list-group-item">
                  <span class="badge">#{value}</span>
                  #{key}
                </li>
              )
      end
      %(
        <ul class="list-group">
          #{list}
        </ul>
      )
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

def with_params *keys
  return unless parameters_present?(*keys)
  values = keys.map { |k| ENV[k.to_s] }
  yield(*values)
end

def parameters_present? *env_keys
  missing = env_keys.select { |k| !ENV[k.to_s] }
  return true if missing.empty?
  missing.each do |key|
    color_puts 'missing parameter:', :red, key
  end
  false
end

def color_puts colored_text, color, text=''
  puts "#{colored_text.send(color.to_s)} #{text}"
end

def write_at fname, at_line, sdat
  open(fname, 'r+') do |f|
    (at_line - 1).times do    # read up to the line you want to write after
      f.readline
    end
    pos = f.pos               # save your position in the file
    rest = f.read             # save the rest of the file
    f.seek pos                # go back to the old position
    f.puts sdat          # write new data & rest of file
    f.puts rest
    color_puts 'created', :green, fname
  end
end

def write_to_mod mod, relative_dir, filename
  mod_dir = File.join 'mod', mod
  dir = File.join mod_dir, relative_dir
  path = File.join dir, filename
  Dir.mkdir(dir) unless Dir.exist?(dir)
  if File.exist?(path)
    color_puts 'file exists', :yellow,  path
  else
    File.open(path, 'w') do |opened_file|
      yield(opened_file)
      color_puts 'created', :green, path
    end
  end
end

def create_content_file mod, name, type
  dir = case type.downcase
        when 'js', 'coffeescript' then 'javascript'
        when 'css', 'scss' then 'stylesheets'
        end
  file_ext = type == 'coffeescript' ? '.js.coffee' : '.' + type
  content_dir = File.join 'lib', dir
  content_file = name + file_ext
  write_to_mod(mod, content_dir, content_file) do |f|
    content = (card = Card.fetch(name)) ? card.content : ''
    f.puts content
  end
end

def create_rb_file mod, name
  self_dir = File.join 'set', 'self'
  self_file = name + '.rb'
  write_to_mod(mod, self_dir, self_file) do |f|
    f.puts('include_set Abstract::CodeFile')
  end
end

def create_migration_file name, type
  puts 'creating migration file...'.yellow
  migration_out = `bundle exec wagn generate card:migration #{name}`
  migration_file = migration_out[/db.*/]
  unless (type_id = Card.fetch_id(type))
    color_puts 'invalid type', :red, type
    return
  end
  codename_string =
    <<-RUBY
    create_or_update name: '#{Card.fetch(name).name}',
                     type_id: #{type_id},
                     codename: '#{name}'
    RUBY
  write_at(migration_file, 5, codename_string) # 5 is line no.
end
