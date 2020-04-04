require "colorize"

namespace :wikirate do
  task :version do
    puts wikirate_version
  end

  task :release do
    version = wikirate_version
    system %(
    git tag -a v#{version} -m "WikiRate Version #{version}"
    git push --tags wikirate
  )
  end

  desc "generate minimal seed data for a fresh start without any data"
  task :generate_seed do |task, _args|
    ensure_env :init_test, task do
      execute_command "rake decko:seed_without_reset", "init_test"
      import_wikirate_essentials
      Delayed::Job.delete_all
      Card::Cache.reset_all
      dump base_dump_path
    end
  end

  task :migrate_seed do |task, _args|
    ensure_env Rails.env, task do
      load_dump base_dump_path
      Rake::Task["decko:migrate"].invoke
      Card::Cache.reset_all
      ActiveRecord::Base.descendants.each(&:reset_column_information)
      Card::Cache.reset_all
      Rake::Task["card:refresh_machine_output"].invoke
      dump dump_path
    end
  end

  task :new_with_subject do
    load_dump dump_path
    Rake::Task["wikirate:change_subject"].invoke
  end

  task change_subject: :environment do
    _task, subject = ARGV
    Card::Cache.reset_all
    Card::Auth.as_bot do
      Card[:wikirate_company].update! name: subject, update_referers: true
      Card.search(type_id: Card::MetricID) do |card|
        card.update! codename: nil if card.codename.present?
        card.delete!
      end
      Card.search(type_id: Card::WikirateCompanyID) do |card|
        card.delete! unless card.codename.present?
      end

      [["Company", subject], ["Companies", subject.pluralize]].each do |old, new|
        sub_in_db old, new
      end
    end
    exit
  end

  def sub_in_db old, new
    Card.search(name: ["match", old]).uniq.each do |card|
      next unless card.simple?
      new_name =
        card.name.gsub(old.capitalize, new.capitalize).gsub(old.downcase, new.downcase)
      card.update! name: new_name, update_referers: true
    end
    Card.search(content: ["match", old]) do |card|
      new_content =
        card.db_content
            .gsub(/\b#{old.capitalize}\b/, new.capitalize)
            .gsub(/\b#{old.downcase}\b/, new.downcase)
      card.update! db_content: new_content
    end
  end

  def import_wikirate_essentials location=:live
    import_from(location) do |import|
      # cardtype has to be the first
      # otherwise codename cards get the wrong type
      import.cards_of_type "cardtype"
      require 'pry'
      binding.pry
      import.items_of :codenames
      # Card::Mod::Loader.reload_sets
      import.cards_of_type "year"

      Card.search(type_id: Card::SettingID, return: :name).each do |setting|
        # TODO: make export view for setting cards
        #   then we don't need to import all script and style cards
        #   we do it via subitems: true
        depth = %w[*script *style *layout].include?(setting) ? 3 : 1
        import.items_of setting, depth: depth
      end
      import.items_of :production_export, depth: 2

      # don't import table migrations
      # exclude = %w(20161005120800 20170118180006 20170210153241 20170303130557
      #            20170330102819)
      import.migration_records # exclude
    end
  end

  def wikirate_version
    File.open(File.expand_path("../../../VERSION", __FILE__)).read.chomp
  end
end
