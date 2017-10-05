# -*- encoding : utf-8 -*-

class AddImportCards < Card::Migration
  def up
    ensure_trait "import status", :import_status,
                 default: { type_id: Card::PlainTextID }
    ensure_trait "imported rows", :imported_rows,
                     default: { type_id: Card::PhraseID }
  end
end
