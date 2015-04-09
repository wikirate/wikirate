# -*- encoding : utf-8 -*-

class ImportSourceReorganization < Card::Migration
  def up
    Card.create! :name=>"script: pdfjs",:codename=>"script_pdfjs",:type=>"JavaScript"
    Card.create! :name=>"script: pdfjs_worker",:codename=>"script_pdfjs_worker",:type=>"JavaScript"
  end
end

