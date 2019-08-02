# -*- encoding : utf-8 -*-

class DeleteUserAnswerStructure < Card::Migration
  def up
    %i[metric_answer metric project].each do |type|
      Card["User+#{type.cardname}+*type plus right+*structure"]&.delete!
    end
    # This structure made USER+answer cards HTML cards, which meant only certain users
    # could create them.  But those cards are needed for `USER+answer+badges earned`.
    # So either we grant permission or we get rid of this structure.  But I couldn't
    # see why this structure was needed, so I vote delete.
    #
    # ...same for User+metric and User+project
  end
end
