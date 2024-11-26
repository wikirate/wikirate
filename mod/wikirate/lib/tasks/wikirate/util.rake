namespace :wikirate do
  namespace :util do
    # desc "remove empty metric value cards"
    # task remove_empty_metric_value_cards: :environment do
    #   # require File.dirname(__FILE__) + '/../config/environment'
    #   # Card::Auth.as_bot
    #   Card::Auth.signin Card::WagnBotID
    #
    #   Card.search(type: "Metric") do |metric|
    #     puts "~~~\n\nworking on METRIC: #{metric.name}"
    #
    #     value_groups = Card.search(
    #       left_id: metric.id,
    #       right: { type: "Company" },
    #       not: {
    #         right_plus: [
    #           { type_id: Card::YearID },
    #           { type_id: Card::AnswerID }
    #         ]
    #       }
    #     )
    #
    #     puts "deleting #{value_groups.size} empty value cards"
    #     value_groups.each do |group_card|
    #       group_card.descendants.each do |desc|
    #         desc.update_column :trash, true
    #       end
    #       group_card.update_column :trash, true
    #     rescue
    #       puts "FAILED TO DELETE: #{group_card.name}"
    #     end
    #   end
    #   puts "empty trash"
    #   Cardio::Utils.empty_trash
    # end

    desc "delete all cards that are marked as trash"
    task "empty_trash" => :environment do
      Cardio::Utils.empty_trash
    end
  end
end
