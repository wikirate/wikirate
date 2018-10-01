require "colorize"

namespace :wikirate do
  desc "fetch json from export card on dev site and generate migration"
  task import_from_staging: :environment do
    import_from_url "https://staging.wikirate.org/export.json?view=export_items"
  end

  desc "fetch json from export card on dev site and generate migration"
  task import_from_dev: :environment do
    import_from_url "https://dev.wikirate.org/export.json?view=export_items"
  end

  desc "fetch json from local export card and generate migration"
  task import_from_local: :environment do
    import_cards do
      Card["export"].format(format: :json).render_export_items
    end
  end

  desc "pull from decko repository to vendor/decko and commit"
  task :decko_tick do |branch|
    _task, branch = ARGV
    branch ||= "wikirate"
    psystem "cd vendor/decko && git pull origin #{branch}"
    psystem "git commit vendor/decko -m 'decko tick'"
    exit
  end

  def import_from_url url
    import_cards do
      JSON.parse(open(url).read).map(&:deep_symbolize_keys)
    end
  end

  def psystem cmd
    puts cmd.green
    system cmd
  end

  def import_cards
    return unless (filename = import_filename_base)
    require "card/migration"
    require "generators/card"
    import_data = yield
    write_card_content! import_data
    write_card_attributes filename, import_data
    system "bundle exec decko generate card:migration #{ENV['name']}"
  end

  def write_card_attributes filename, card_attributes
    path = Card::Migration.data_path("#{filename}.json")
    File.open(path, "w") do |f|
      f.print JSON.pretty_generate(card_attributes)
    end
  end

  # removes and writes the content field
  def write_card_content! import_data
    import_data.each do |card_attr|
      path = File.join "cards", card_attr[:name].to_name.key
      File.open(Card::Migration.data_path(path), "w") do |f|
        f.puts card_attr.delete :content
      end
    end
  end

  def import_filename_base
    return import_filename_missing unless (envname = ENV["name"])
    filename_base_from_envname(envname) || invalid_filename_in_env
  end

  def filename_base_from_envname envname
    m = envname.match /^(?:import)_(.*)(?:\.json)?/
    m && m[1]
  end

  def import_filename_missing
    puts "pass a name for the migration 'name=...'"
    nil
  end

  def invalid_filename_in_env
    puts "invalid format: name must match /import_(.*)/"
    nil
  end
end
