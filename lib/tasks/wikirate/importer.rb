require_relative "import_card"

class Importer
  attr_reader :export_location
  def initialize location
    @export_location =
      case location
      when "dev"    then "dev.wikirate.org"
      when "demo"   then "demo.wikirate.org"
      when "local"  then "localhost:3000"
      else               "wikirate.org"
      end
  end

  # @return [Array<Hash>] each hash contains the attributes for a card
  def items_of cardname, opts={}
    card_data =
      work_on "getting data from #{cardname} card" do
        if opts[:subitems]
          json_export cardname, :export_items
        else
          json_export(cardname)["card"]["value"]
        end
      end
    import_card_data card_data
  end

  def cards_of_type type
    items_of "#{type}+*type+by_update"
  end

  def migration_records *exclude
    migration_data =
      work_on "getting migration records" do
        json_export :admin_info, :migrations
      end
    work_on "importing migration records" do
      import_migration_data migration_data, exclude.flatten
    end
  end

  def rerun_migrations *versions
    versions.flatten.each do |version|
      system "bundle exec rake wagn:migrate:redo VERSION=#{version}"
    end
  end

  private

  def work_on msg
    puts msg.green
    result = yield
    puts " ... done".green
    result
  end

  def json_export cardname, view=nil
    name = cardname.is_a?(Symbol) ? ":#{cardname}" : cardname.to_name.key
    url = "http://#{@export_location}/#{name}.json"
    url += "?view=#{view}" if view
    JSON.parse open(url, read_timeout: 50_000).read
  end

  def import_card_data cards
    work_on "importing data (#{cards.size} cards)" do
      Card::Auth.as_bot do
        cards.flatten.each do |card|
          ImportCard.new(card).update_or_create
        end
      end
    end
  end

  def import_migration_data data, exclude
    exclude = Array(exclude).flatten.map(&:to_s)
    data.each do |table, values|
      begin
        truncate table
        insert_into table, (values - exclude)
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
