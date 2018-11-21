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
      execute_command "rake decko:seed_without_reset", Rails.env
      Rake::Task["wikirate:test:import_from"].invoke
      Delayed::Job.delete_all
    end
    Rake::Task["wikirate:migrate_seed"].invoke
  end

  task :migrate_seed do |task, _args|
    ensure_env Rails.env, task do
      dump base_dump_path
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

  task change_subject: :environment do |subject|
    _task, subject = ARGV
    Card::Cache.reset_all
    Card::Auth.as_bot do
      Card[:wikirate_company].update_attributes! name: subject, update_referers: true
      Card.search(type_id: Card::MetricID) do |card|
        card.update_attributes! codename: nil if card.codename.present?
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
      card.update_attributes! name: new_name, update_referers: true
    end
    Card.search(content: ["match", old]) do |card|
      new_content =
        card.db_content
            .gsub(/\b#{old.capitalize}\b/, new.capitalize)
            .gsub(/\b#{old.downcase}\b/, new.downcase)
      card.update_attributes! db_content: new_content
    end
  end

  def wikirate_version
    File.open(File.expand_path("../../../VERSION", __FILE__)).read.chomp
  end
end
