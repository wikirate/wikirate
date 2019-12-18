# -*- encoding : utf-8 -*-

class AddImportTool < Card::Migration
  def up
    ensure_card "import_tool",
                type_id: Card::HtmlID,
                codename: "import_tool"
  end
end
