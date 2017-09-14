# -*- encoding : utf-8 -*-

class AddCodenameForReportType < Card::Migration
  def up
    ensure_card "Report type", codename: "report_type"
  end
end
