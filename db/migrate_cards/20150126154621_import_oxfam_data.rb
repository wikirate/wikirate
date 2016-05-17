# -*- encoding : utf-8 -*-

class ImportOxfamData < Card::Migration
  def up
    Card.create! name: "Oxfam spreadsheet 2014", codename: "oxfam_spreadsheet", type: "file", file: File.new(data_path("oxfam-scorecard-2014.xlsx")),
                 subcards: { "+*self+*read" => { content: "[[Administrator]]", type: "pointer" } }
  end
end
