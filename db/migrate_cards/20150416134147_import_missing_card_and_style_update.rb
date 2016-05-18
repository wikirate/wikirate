# -*- encoding : utf-8 -*-

class ImportMissingCardAndStyleUpdate < Card::Migration
  def up
    import_json "missing_card_and_style_update.json"
    unless File.exist?"#{Rails.root}/public/pdfjs"
      FileUtils.ln_s "#{Rails.root}/mod/pdfjs/files", "#{Rails.root}/public/pdfjs"
    end
  end
end
