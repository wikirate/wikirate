# -*- encoding : utf-8 -*-

class AddImportCards < Card::Migration
  def up
    ensure_trait "import status", :import_status,
                 default: { type_id: Card::SessionID }
  end
end
