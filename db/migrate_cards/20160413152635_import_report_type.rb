# -*- encoding : utf-8 -*-

class ImportReportType < Card::Migration
  def up
    import_json "report_type.json"
  end
end
