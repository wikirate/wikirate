# -*- encoding : utf-8 -*-

class AddMetricImportType < Card::Migration
  def up
    ensure_code_card "Metric Import", type_id: Card::CardtypeID

    { answer_import_file: "Answer Import",
      relationship_answer_import_file: "Relationship Import",
      source_import_file: "Source Import"
    }.each do |old_code, new_name|
      update_card old_code, name: new_name, codename: codename_from_name(new_name)
    end
  end
end
