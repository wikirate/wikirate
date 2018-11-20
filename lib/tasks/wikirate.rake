require "colorize"

namespace :wikirate do
  base_dump_path = File.join Decko.root, "db", "base_seed.db"
  dump_path = File.join Decko.root, "test", "seed.db"
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

  def sub_in_db old, new
    Card.search(name: ["match", old]).uniq.each do |card|
      next unless card.simple?
      new_name =
        card.name.gsub(old.capitalize, new.capitalize).gsub(old.downcase, new.downcase)
      card.update_attributes! name: new_name, update_referers: true
    end
    Card.search(content: ["match", old]) do |card|
      new_content =
        card.db_content.gsub(old.capitalize, new.capitalize).gsub(old.downcase, new.downcase)
      card.update_attributes! db_content: new_content
    end
  end


  desc "seed with raw decko db and import cards"
  task :generate_seed, [:location] do |task, args|
    # init_test env uses the same db as test env
    # test env triggers stuff on load that breaks the seeding process
    ensure_env :init_test, task, args do
      # with_env_var "CARD_MODS", "none" do
      execute_command "rake decko:seed_without_reset", :production
      Rake::Task["wikirate:test:import_from"].invoke(args[:location])
      Delayed::Job.delete_all
      Rake::Task["wikirate:test:dump"].invoke(base_dump_path)
    end
    binding.pry
    ensure_env Rails.env, task do
      Rake::Task["wikirate:test:load_dump"].invoke(base_dump_path)
      Rake::Task["decko:migrate"].invoke
      Card::Cache.reset_all
      ActiveRecord::Base.descendants.each{ |c| c.reset_column_information }
      Card::Cache.reset_all
      Rake::Task["card:refresh_machine_output"].invoke
      Rake::Task["wikirate:test:dump"].invoke(dump_path)
    end
  end



  task :new_with_subject do
    ENV["DATABASE_NAME_TEST"] =
      Decko.config.database_configuration.dig(Rails.env, "database")
    Rake::Task["wikirate:test:load_dump"].invoke(dump_path)
    Rake::Task["wikirate:change_subject"].invoke
  end

  task change_subject: :environment do |subject|
    _task, subject = ARGV
    Card::Cache.reset_all
    Card::Auth.as_bot do
      Card[:wikirate_company].update_attributes! name: subject, update_referers: true
      # Card.search(type_id: Card::MetricID) do |card|
      #   next if card.codename.present?
      #   card.delete!
      # end
      Card.search(type_id: Card::WikirateCompanyID) do |card|
        next if card.codename.present?
        card.delete!
      end

      [["Company", subject], ["Companies", subject.pluralize]].each do |old, new|
        sub_in_db old, new
      end
    end
    exit
  end


  def wikirate_version
    File.open(File.expand_path("../../../VERSION", __FILE__)).read.chomp
  end

  namespace :util do
    desc "remove empty metric value cards"
    task remove_empty_metric_value_cards: :environment do
      # require File.dirname(__FILE__) + '/../config/environment'
      # Card::Auth.as_bot
      Card::Auth.current_id = Card::WagnBotID

      Card.search(type: "Metric") do |metric|
        puts "~~~\n\nworking on METRIC: #{metric.name}"

        value_groups = Card.search(
          left_id: metric.id,
          right: { type: "Company" },
          not: {
            right_plus: [
              { type_id: Card::YearID },
              { type_id: Card::MetricAnswerID }
            ]
          }
        )

        puts "deleting #{value_groups.size} empty value cards"
        value_groups.each do |group_card|
          group_card.descendants.each do |desc|
            desc.update_column :trash, true
          end
          group_card.update_column :trash, true
        rescue
          puts "FAILED TO DELETE: #{group_card.name}"
        end
      end
      puts "empty trash"
      Card.empty_trash
    end

    desc "delete all cards that are marked as trash"
    task "empty_trash" => :environment do
      Card.empty_trash
    end
  end
end
