# -*- encoding : utf-8 -*-

class AnswerSourceHandling < Card::Migration
  def up
    add_script "answer source handling",
               type_id: Card::CoffeeScriptID,
               to: "script: wikirate scripts"
  end
end
