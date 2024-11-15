require File.expand_path "../../../config/environment", __FILE__
require "json"
require "colorize"

Card::Auth.signin "Ethan McCutchen"
Card::Auth.as_bot

Cardio.config.perform_deliveries = false

# migrate old check requests to flags
module ChecksToFlags
  class << self
    def run!
      each_check_request do |record, checked_by|
        if record.value_card.unknown_value?
          delete_card checked_by
        elsif record.discussion.present?
          add_flag record, checked_by
          delete_card checked_by
        else
          puts "record has NO discussion".yellow
        end
      end
    end

    private

    def add_flag record, checked_by
      with_request_context checked_by do
        puts "flagging #{record.name}".green
        Card.create! type: :flag,
                     fields: {
                       flag_type: "Wrong Value",
                       discussion: record.discussion,
                       subject: record.name
                     }
      end
    rescue StandardError => e
      puts "Error flagging #{record.name}: #{e.message}".red
    end

    def delete_card checked_by
      puts "deleting #{checked_by.name}".blue
      Card::Auth.signin "Ethan McCutchen"
      checked_by.delete!
    rescue StandardError => e
      puts "Error deleting #{checked_by.name}: #{e.message}".red
    end

    def with_request_context checked_by, &block
      Card::Auth.signin checked_by.updater
      Timecop.freeze checked_by.updated_at, &block
    end

    # note: check requests on an record set the content of its +checked_by card to "request"
    def each_check_request
      Card.where(right_id: Card::CheckedByID).find_each do |checked_by|
        checked_by.include_set_modules
        record = checked_by.left
        next unless record.type_code == :record

        yield record, checked_by
      end
    end
  end
end

ChecksToFlags.run!
