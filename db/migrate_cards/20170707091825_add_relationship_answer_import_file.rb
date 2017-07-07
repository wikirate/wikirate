# -*- encoding : utf-8 -*-

class AddRelationshipAnswerImportFile < Card::Migration
  def up
    create "relationship answer import file",
           codename: "relationship_answer_import_file",
           type_id: Card::CardtypeID
  end
end
