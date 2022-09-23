# -*- encoding : utf-8 -*-

require "timecop"

class ChecksToFlags < Cardio::Migration
  def up
    each_check_request do |answer, checked_by|
      if answer.value_card.unknown_value?
        delete_card checked_by
      elsif answer.discussion.present?
        add_flag answer, checked_by
        delete_card checked_by
      end
    end
  end

  private

  def add_flag answer, checked_by
    with_request_context checked_by do
      Card.create! type: :flag,
                   fields: {
                     flag_type: "Wrong Value",
                     discussion: answer.discussion,
                     subject: answer.name
                   }
    end
  end

  def delete_card checked_by
    Card::Auth.signin "Ethan McCutchen"
    checked_by.delete!
  end

  def with_request_context checked_by, &block
    Card::Auth.signin checked_by.updater
    Timecop.freeze checked_by.updated_at &block
  end

  # note: check requests on an answer set the content of its +checked_by card to "request"
  def each_check_request
    Card.search left: { type: "Answer" }, right: :checked_by, eq: "request" do |checked_by|
      yield checked_by.left, checked_by
    end
  end
end
