# -*- encoding : utf-8 -*-

require "timecop"
require "colorize"

class ChecksToFlags < Cardio::Migration
  def up
    each_check_request do |answer, checked_by|
      if answer.value_card.unknown_value?
        puts "answer unknown!".yellow
        delete_card checked_by
      elsif answer.discussion.present?
        puts "answer has discussion".yellow
        add_flag answer, checked_by
        delete_card checked_by
      else
        puts "answer has NO discussion".yellow
      end
    end
    raise "dont do it"
  end

  private

  def add_flag answer, checked_by
    with_request_context checked_by do
      puts "flagging #{answer.name}".green
      Card.create! type: :flag,
                   fields: {
                     flag_type: "Wrong Value",
                     discussion: answer.discussion,
                     subject: answer.name
                   }
    end
  rescue StandardError => e
    puts "Error flagging #{answer.name}: #{e.message}".red
  end

  def delete_card checked_by
    puts "deleting #{checked_by.name}".blue
    Card::Auth.signin "Ethan McCutchen"
    # checked_by.delete!
  rescue StandardError => e
    puts "Error deleting #{checked_by.name}: #{e.message}".red
  end

  def with_request_context checked_by, &block
    Card::Auth.signin checked_by.updater
    Timecop.freeze checked_by.updated_at, &block
  end

  # note: check requests on an answer set the content of its +checked_by card to "request"
  def each_check_request
    Card.where(right_id: Card::CheckedByID).limit(100).find_each do |checked_by|
      checked_by.include_set_modules
      answer = checked_by.left
      next unless answer.type_code == :metric_answer

      yield answer, checked_by
    end
  end
end
