# -*- encoding : utf-8 -*-

class AddRelationshipAnswerImportFile < Card::Migration
  def up
    ensure_card "relationship answer import file",
           codename: "relationship_answer_import_file",
           type_id: Card::CardtypeID

    ensure_card "new relationship answer import file",
           codename: "new_relationship_answer_import_file",
           type_id: Card::FileID, empty_ok: true
  end
end
