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
              { type: "Year" },
              { type: "Metric Value" }
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
      puts "empty trash"
      Card.empty_trash
    end

    desc "delete all cards that are marked as trash"
    task "empty_trash" => :environment do
      Card.empty_trash
    end
  end
end
